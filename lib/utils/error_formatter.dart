String formatError(dynamic error) {
  if (error == null) return '';
  String msg = error.toString();

  msg = msg.replaceAll(RegExp(r'^(SocketException|HandshakeException|TlsException|TimeoutException|ClientException|HttpException|Exception|Error):\s*', caseSensitive: false), '');

  msg = msg.replaceAll(RegExp(r'\b(SocketException|HandshakeException|TlsException|TimeoutException|ClientException|HttpException|Exception|Error)\b\s*:?\s*', caseSensitive: false), '');

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
