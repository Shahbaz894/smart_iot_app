/// Base exception for the entire application.
/// Every error in the app MUST extend this.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}
