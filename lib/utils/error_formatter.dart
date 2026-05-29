String formatError(dynamic error) {
  if (error == null) return '';
  String msg = error.toString();

  msg = msg.replaceAll(RegExp(r'^(SocketException|HandshakeException|TlsException|TimeoutException|ClientException|HttpException|FirebaseException|PlatformException|Exception|Error):\s*', caseSensitive: false), '');

  msg = msg.replaceAll(RegExp(r'\b(SocketException|HandshakeException|TlsException|TimeoutException|ClientException|HttpException|FirebaseException|PlatformException|Exception|Error)\b\s*:?\s*', caseSensitive: false), '');

  final msgLower = msg.toLowerCase();

  if (msg.contains('Failed host lookup') ||
      msg.contains('OS Error') ||
      msg.contains('Network is unreachable') ||
      msg.contains('Connection refused') ||
      msgLower.contains('socket') ||
      msgLower.contains('handshake') ||
      msgLower.contains('tls') ||
      msgLower.contains('network-error') ||
      msgLower.contains('network_error') ||
      msgLower.contains('unavailable')) {
    return 'Gagal terhubung ke internet. Periksa koneksi Anda.';
  }

  if (msg.contains('Permintaan kedaluwarsa') ||
      msgLower.contains('timeout') ||
      msgLower.contains('time out')) {
    return 'Koneksi lambat atau permintaan kedaluwarsa. Silakan coba lagi.';
  }

  if (msgLower.contains('gps') ||
      msgLower.contains('location service') ||
      msgLower.contains('location_service') ||
      msgLower.contains('layanan lokasi') ||
      msgLower.contains('disabled')) {
    return 'Layanan lokasi (GPS) belum aktif. Aktifkan GPS untuk mendeteksi lokasi Anda.';
  }

  if (msgLower.contains('permanently denied') ||
      msgLower.contains('deniedforever') ||
      (msgLower.contains('denied') && msgLower.contains('permanent'))) {
    return 'Izin lokasi ditolak secara permanen. Aktifkan izin lokasi di pengaturan perangkat Anda.';
  }

  if (msgLower.contains('denied') || msgLower.contains('permission')) {
    return 'Izin akses lokasi ditolak. Aktifkan izin lokasi agar aplikasi dapat mendeteksi jadwal shalat otomatis.';
  }

  if (msgLower.contains('geocoding') || msgLower.contains('placemark')) {
    return 'Gagal menerjemahkan koordinat lokasi. Periksa koneksi internet Anda.';
  }

  return msg.trim();
}
