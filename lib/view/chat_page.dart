import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_view_model.dart';
import '../utils/logger.dart';
import '../gemini_config.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Assalamualaikum! Saya Asisten Muslim AI. Ada yang bisa saya bantu hari ini mengenai ajaran Islam, doa, jadwal shalat, atau yang lainnya?',
      'isUser': false,
    }
  ];
  bool _isLoading = false;
  String? _lastUserId;

  /// Maximum number of messages allowed in a single chat session.
  /// Prevents unbounded memory growth and API cost abuse.
  static const int _maxSessionMessages = 50;

  /// Maximum number of history messages sent to the API.
  /// Limits token usage and prevents exponentially growing payloads.
  static const int _maxApiHistoryMessages = 20;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authVm = Provider.of<AuthViewModel>(context);
    if (_lastUserId != authVm.userId) {
      _lastUserId = authVm.userId;
      _clearChatHistory();
    }
  }

  void _clearChatHistory() {
    setState(() {
      _messages.clear();
      _messages.add({
        'text': 'Assalamualaikum! Saya Asisten Muslim AI. Ada yang bisa saya bantu hari ini mengenai ajaran Islam, doa, jadwal shalat, atau yang lainnya?',
        'isUser': false,
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_isLoading) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (text.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesan tidak boleh lebih dari 2000 karakter.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Enforce maximum session message count to prevent abuse
    if (_messages.length >= _maxSessionMessages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batas sesi tercapai. Silakan mulai percakapan baru.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _messageController.clear();
    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Only send the last N messages as history to limit API token cost
      final allHistory = _messages.sublist(1, _messages.length - 1);
      final history = allHistory.length > _maxApiHistoryMessages
          ? allHistory.sublist(allHistory.length - _maxApiHistoryMessages)
          : allHistory;
      final List<Map<String, dynamic>> contents = [];

      for (var msg in history) {
        if (msg['isError'] == true) continue; // Skip error messages
        contents.add({
          'role': msg['isUser'] ? 'user' : 'model',
          'parts': [
            {'text': msg['text']}
          ]
        });
      }

      contents.add({
        'role': 'user',
        'parts': [
          {'text': text}
        ]
      });

      final body = {
        'contents': contents,
        'systemInstruction': {
          'parts': [
            {
              'text':
                  'Anda adalah asisten Muslim AI yang sopan, ramah, dan berpengetahuan luas tentang ajaran Islam. PENTING: Anda HANYA diperbolehkan menjawab pertanyaan yang berkaitan dengan ajaran Islam, ibadah, doa, Al-Quran, Hadis, sejarah Islam, hukum fiqih, akhlak, dan topik keislaman lainnya. Jika pengguna mengajukan pertanyaan di luar topik keislaman (seperti sains umum, matematika, pemrograman komputer, berita politik umum, hiburan umum, dll.), Anda HARUS menolaknya secara sopan dengan menyatakan bahwa Anda hanya didesain untuk menjawab pertanyaan seputar ajaran Islam. Berikan jawaban keislaman yang sejalan dengan ajaran Ahlussunnah wal Jama\'ah, menggunakan referensi Al-Quran, Hadis, serta penjelasan yang sejuk, moderat (wasathiyah), dan mudah dipahami. Hindari berdebat mengenai masalah khilafiyah secara keras, jelaskan perbedaan pendapat ulama secara bijaksana jika diperlukan.'
            }
          ]
        }
      };

      // SECURITY: This API key is loaded from gemini_config.dart which is gitignored.
      // Ensure this key is restricted in Google Cloud Console:
      // 1. Application restriction → Android apps → package: id.muslimapp.app
      // 2. API restriction → Generative Language API only
      // 3. Set daily quota limit (e.g. 1000 requests/day)
      // TODO: Migrate to Cloud Function proxy when Blaze plan is available
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${GeminiConfig.apiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        setState(() {
          _messages.add({'text': responseText.trim(), 'isUser': false});
          _isLoading = false;
        });
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.warningLazy(() => 'Error in chat AI: $e');
      setState(() {
        _messages.add({
          'text':
              'Maaf, saya sedang mengalami kendala koneksi untuk menghubungi server. Silakan coba lagi beberapa saat lagi.',
          'isUser': false,
          'isError': true,
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tanya Muslim AI',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator(theme);
                }

                final message = _messages[index];
                final isUser = message['isUser'] as bool;
                final isError = message['isError'] == true;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.colorScheme.primary
                          : (isError
                              ? theme.colorScheme.errorContainer
                              : theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.25)),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                    ),
                    child: isUser
                        ? Text(
                            message['text'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              height: 1.4,
                            ),
                          )
                        : MarkdownBody(
                            data: message['text'] as String,
                            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                              p: theme.textTheme.bodyMedium?.copyWith(
                                color: isError
                                    ? theme.colorScheme.onErrorContainer
                                    : theme.colorScheme.onSurface,
                                height: 1.4,
                              ),
                              strong: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isError
                                    ? theme.colorScheme.onErrorContainer
                                    : theme.colorScheme.onSurface,
                              ),
                              em: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: isError
                                    ? theme.colorScheme.onErrorContainer
                                    : theme.colorScheme.onSurface,
                              ),
                              h1: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isError
                                    ? theme.colorScheme.onErrorContainer
                                    : theme.colorScheme.onSurface,
                              ),
                              h2: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isError
                                    ? theme.colorScheme.onErrorContainer
                                    : theme.colorScheme.onSurface,
                              ),
                              h3: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isError
                                    ? theme.colorScheme.onErrorContainer
                                    : theme.colorScheme.onSurface,
                              ),
                              listBullet: theme.textTheme.bodyMedium?.copyWith(
                                color: isError
                                    ? theme.colorScheme.onErrorContainer
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Muslim AI sedang mengetik...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.bodyMedium,
                maxLines: null,
                maxLength: 2000,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Tanyakan sesuatu tentang Islam...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _isLoading ? null : _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send_rounded),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
