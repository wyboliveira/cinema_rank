import 'package:logger/logger.dart';

// Singleton de logging para toda a aplicação.
// Uso: AppLogger.info('mensagem', {'chave': 'valor'});
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  static void debug(String message, [Map<String, dynamic>? context]) =>
      _logger.d(_format(message, context));

  static void info(String message, [Map<String, dynamic>? context]) =>
      _logger.i(_format(message, context));

  static void warning(String message, [Map<String, dynamic>? context]) =>
      _logger.w(_format(message, context));

  static void error(
    String message,
    dynamic error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ]) =>
      _logger.e(_format(message, context), error: error, stackTrace: stackTrace);

  static String _format(String message, Map<String, dynamic>? context) {
    if (context == null || context.isEmpty) return message;
    final pairs = context.entries.map((e) => '${e.key}=${e.value}').join(', ');
    return '$message | $pairs';
  }
}