const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

// Rate limit tracking (in-memory, resets on cold start)
const rateLimitMap = new Map();
const RATE_LIMIT_MAX = 30; // max requests
const RATE_LIMIT_WINDOW_MS = 60 * 1000; // per 1 minute

// Allowed fields in the request body
const ALLOWED_BODY_FIELDS = new Set(["contents"]);
const MAX_BODY_SIZE_BYTES = 100 * 1024; // 100KB

exports.generateChatResponse = onRequest({ cors: false }, async (req, res) => {
  try {
    // Only allow POST requests
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    // 1. Authenticate using the Firebase ID Token passed in the Authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      logger.warn("Unauthorized request: Missing or invalid Authorization header");
      res.status(401).send("Unauthorized: Missing or invalid token");
      return;
    }

    const idToken = authHeader.split("Bearer ")[1];
    
    // Verify the Firebase ID Token to ensure the caller is an authenticated user of our app
    let decodedToken;
    try {
      decodedToken = await admin.auth().verifyIdToken(idToken);
      logger.info(`Authenticated request from user: ${decodedToken.uid}`);
    } catch (authError) {
      logger.error("Token verification failed:", authError);
      res.status(401).send("Unauthorized: Token verification failed");
      return;
    }

    // 2. Rate limiting per authenticated user
    const uid = decodedToken.uid;
    const now = Date.now();
    if (!rateLimitMap.has(uid)) {
      rateLimitMap.set(uid, []);
    }
    const timestamps = rateLimitMap.get(uid).filter(t => now - t < RATE_LIMIT_WINDOW_MS);
    if (timestamps.length >= RATE_LIMIT_MAX) {
      logger.warn(`Rate limit exceeded for user: ${uid}`);
      res.status(429).send("Too Many Requests: Please wait before sending more messages.");
      return;
    }
    timestamps.push(now);
    rateLimitMap.set(uid, timestamps);

    // 3. Validate request body size
    const bodyStr = JSON.stringify(req.body);
    if (bodyStr.length > MAX_BODY_SIZE_BYTES) {
      logger.warn(`Request body too large from user: ${uid} (${bodyStr.length} bytes)`);
      res.status(413).send("Payload Too Large: Request body exceeds 100KB limit.");
      return;
    }

    // 4. Validate and sanitize request body — only allow known fields
    const body = req.body;
    if (!body || typeof body !== "object") {
      res.status(400).send("Bad Request: Invalid body");
      return;
    }

    const sanitizedBody = {};
    for (const key of Object.keys(body)) {
      if (ALLOWED_BODY_FIELDS.has(key)) {
        sanitizedBody[key] = body[key];
      }
    }

    if (!sanitizedBody.contents || !Array.isArray(sanitizedBody.contents)) {
      res.status(400).send("Bad Request: Missing or invalid 'contents' field");
      return;
    }

    // 5. Enforce system instruction on server-side (cannot be overridden by client)
    sanitizedBody.systemInstruction = {
      parts: [
        {
          text: "Anda adalah asisten Muslim AI yang sopan, ramah, dan berpengetahuan luas tentang ajaran Islam. PENTING: Anda HANYA diperbolehkan menjawab pertanyaan yang berkaitan dengan ajaran Islam, ibadah, doa, Al-Quran, Hadis, sejarah Islam, hukum fiqih, akhlak, dan topik keislaman lainnya. Jika pengguna mengajukan pertanyaan di luar topik keislaman (seperti sains umum, matematika, pemrograman komputer, berita politik umum, hiburan umum, dll.), Anda HARUS menolaknya secara sopan dengan menyatakan bahwa Anda hanya didesain untuk menjawab pertanyaan seputar ajaran Islam. Berikan jawaban keislaman yang sejalan dengan ajaran Ahlussunnah wal Jama'ah, menggunakan referensi Al-Quran, Hadis, serta penjelasan yang sejuk, moderat (wasathiyah), dan mudah dipahami. Hindari berdebat mengenai masalah khilafiyah secara keras, jelaskan perbedaan pendapat ulama secara bijaksana jika diperlukan."
        }
      ]
    };

    // 6. Retrieve API key from environment variable ONLY — no hardcoded fallback
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      logger.error("GEMINI_API_KEY environment variable is not set.");
      res.status(500).send("Internal Server Error: API key not configured.");
      return;
    }

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${apiKey}`;

    const response = await fetch(geminiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(sanitizedBody)
    });

    const data = await response.json();
    res.status(response.status).json(data);
  } catch (error) {
    logger.error("Error in generateChatResponse proxy function:", error);
    res.status(500).send("Internal Server Error");
  }
});
