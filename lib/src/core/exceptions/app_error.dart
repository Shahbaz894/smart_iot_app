import 'app_exception.dart';

class AppError extends AppException {
  const AppError({
    required String message,
    String? code,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    stackTrace: stackTrace,
  );
}