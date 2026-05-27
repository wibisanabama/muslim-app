import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class AppLogger {
  static final Logger _logger = Logger('MuslimApp');
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    if (kReleaseMode) {
      Logger.root.level = Level.OFF;
    } else {
      Logger.root.level = Level.ALL;
    }

    Logger.root.onRecord.listen((record) {
      if (kReleaseMode) return;

      final timeStr = record.time
          .toIso8601String()
          .split('T')
          .last
          .substring(0, 12);
      final logMsg =
          '[$timeStr] [${record.level.name}] [${record.loggerName}]: ${record.message}';

      if (record.error != null) {
        debugPrint('$logMsg\nError: ${record.error}');
      } else {
        debugPrint(logMsg);
      }
      if (record.stackTrace != null) {
        debugPrint(record.stackTrace.toString());
      }
    });
  }

  static void info(String message) {
    if (kReleaseMode) return;
    _logger.info(message);
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (kReleaseMode) return;
    _logger.warning(message, error, stackTrace);
  }

  static void severe(String message, [Object? error, StackTrace? stackTrace]) {
    if (kReleaseMode) return;
    _logger.severe(message, error, stackTrace);
  }

  static void debug(String message) {
    if (kReleaseMode) return;
    _logger.config(message);
  }

  static void infoLazy(String Function() messageBuilder) {
    if (kReleaseMode) return;
    _logger.info(messageBuilder());
  }

  static void warningLazy(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kReleaseMode) return;
    _logger.warning(messageBuilder(), error, stackTrace);
  }

  static void severeLazy(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kReleaseMode) return;
    _logger.severe(messageBuilder(), error, stackTrace);
  }

  static void debugLazy(String Function() messageBuilder) {
    if (kReleaseMode) return;
    _logger.config(messageBuilder());
  }
}
