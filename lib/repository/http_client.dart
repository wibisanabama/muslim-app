import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class PayloadTooLargeException implements Exception {
  final String message;
  PayloadTooLargeException([
    this.message = 'Respons server tidak valid (terlalu besar)',
  ]);
  @override
  String toString() => message;
}

class SafeHttpClient extends http.BaseClient {
  final http.Client _inner;
  final int maxBytes;

  SafeHttpClient(this._inner, {this.maxBytes = 5 * 1024 * 1024});

  http.BaseRequest _cloneRequest(http.BaseRequest original) {
    if (original is http.Request) {
      final clone = http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..bodyBytes = original.bodyBytes
        ..persistentConnection = original.persistentConnection
        ..followRedirects = original.followRedirects
        ..maxRedirects = original.maxRedirects;
      return clone;
    }
    return original;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    int attempt = 0;
    const maxAttempts = 4;
    Duration backoffDelay = const Duration(seconds: 1);

    while (true) {
      attempt++;
      try {
        final currentRequest = attempt == 1 ? request : _cloneRequest(request);
        final responseFuture = _inner.send(currentRequest);
        final streamedResponse = await responseFuture.timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Permintaan kedaluwarsa'),
        );

        if (streamedResponse.contentLength != null &&
            streamedResponse.contentLength! > maxBytes) {
          throw PayloadTooLargeException(
            'Respons terlalu besar (melebihi ${maxBytes ~/ (1024 * 1024)} MB)',
          );
        }

        if (streamedResponse.statusCode >= 500 && attempt < maxAttempts) {
          await Future.delayed(backoffDelay);
          backoffDelay *= 2;
          continue;
        }

        int bytesReceived = 0;
        final transformedStream = streamedResponse.stream.transform<List<int>>(
          StreamTransformer.fromHandlers(
            handleData: (chunk, sink) {
              bytesReceived += chunk.length;
              if (bytesReceived > maxBytes) {
                sink.addError(
                  PayloadTooLargeException(
                    'Respons terlalu besar (melebihi ${maxBytes ~/ (1024 * 1024)} MB)',
                  ),
                );
              } else {
                sink.add(chunk);
              }
            },
          ),
        );

        return http.StreamedResponse(
          transformedStream,
          streamedResponse.statusCode,
          headers: streamedResponse.headers,
          isRedirect: streamedResponse.isRedirect,
          persistentConnection: streamedResponse.persistentConnection,
          reasonPhrase: streamedResponse.reasonPhrase,
          request: currentRequest,
          contentLength: streamedResponse.contentLength,
        );
      } catch (e) {
        if (e is PayloadTooLargeException || e is TimeoutException) {
          rethrow;
        }

        final isTls = e is TlsException ||
            e.toString().contains('HandshakeException') ||
            e.toString().contains('TlsException') ||
            e.toString().contains('CERTIFICATE_VERIFY_FAILED');

        final isSocket = e is SocketException ||
            e.toString().contains('SocketException') ||
            e.toString().contains('Failed host lookup');

        if ((isTls || isSocket) && attempt < maxAttempts) {
          await Future.delayed(backoffDelay);
          backoffDelay *= 2;
          continue;
        }

        if (isTls) {
          throw const TlsException('Koneksi aman tidak dapat dibuat');
        }

        if (isSocket) {
          throw const SocketException('Gagal terhubung ke internet. Periksa koneksi Anda.');
        }

        rethrow;
      }
    }
  }
}

http.Client createSafeHttpClient({int maxBytes = 5 * 1024 * 1024}) {
  return SafeHttpClient(http.Client(), maxBytes: maxBytes);
}

Future<http.Response> safeGet(http.Client client, Uri url) async {
  return await client.get(url);
}
