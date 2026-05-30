const Object _unset = Object();

class LoginState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? error;
  final String? message;
  final String? userId;
  final String? email;
  final String? name;
  final String? deviceId;

  const LoginState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.error,
    this.message,
    this.userId,
    this.email,
    this.name,
    this.deviceId,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    Object? error = _unset,
    Object? message = _unset,
    Object? userId = _unset,
    Object? email = _unset,
    Object? name = _unset,
    Object? deviceId = _unset,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      error: error == _unset ? this.error : error as String?,
      message: message == _unset ? this.message : message as String?,
      userId: userId == _unset ? this.userId : userId as String?,
      email: email == _unset ? this.email : email as String?,
      name: name == _unset ? this.name : name as String?,
      deviceId: deviceId == _unset ? this.deviceId : deviceId as String?,
    );
  }
}