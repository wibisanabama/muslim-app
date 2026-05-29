String formatError(dynamic error) {
  if (error == null) return '';
  String msg = error.toString();

  // Strip common technical prefix wrappers
  msg = msg.replaceAll(RegExp(r'^(SocketException|HandshakeException|TlsException|TimeoutException|ClientException|HttpException|Exception|Error):\s*', caseSensitive: false), '');

  // Strip lingering technical exception patterns anywhere in the string
  msg = msg.replaceAll(RegExp(r'\b(SocketException|HandshakeException|TlsException|TimeoutException|ClientException|HttpException|Exception|Error)\b\s*:?\s*', caseSensitive: false), '');

  // Map known technical messages to highly user-friendly Indonesian messages
  if (msg.contains('Failed host lookup') ||
      msg.contains('OS Error') ||
      msg.contains('Network is unreachable') ||
      msg.contains('Connection refused') ||
      msg.toLowerCase().contains('socket') ||
      msg.toLowerCase().contains('handshake') ||
      msg.toLowerCase().contains('tls')) {
    return 'Gagal terhubung ke internet. Periksa koneksi Anda.';
  }

  if (msg.contains('Permintaan kedaluwarsa') || msg.toLowerCase().contains('timeout')) {
    return 'Koneksi lambat atau permintaan kedaluwarsa. Silakan coba lagi.';
  }

  return msg.trim();
}
