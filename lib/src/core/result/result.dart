import 'package:smart_iot_app/src/core/exceptions/device_exception.dart';





sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final DeviceException error;
  const Failure(this.error);
}
