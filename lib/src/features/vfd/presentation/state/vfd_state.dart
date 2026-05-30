class VfdState {
  final bool isLoading;
  final String? error;
  final String? message;

  const VfdState({
    this.isLoading = false,
    this.error,
    this.message,
  });

  VfdState copyWith({
    bool? isLoading,
    String? error,
    String? message,
  }) {
    return VfdState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
    );
  }
}