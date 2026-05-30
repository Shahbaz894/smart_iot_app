import "../../data/models/khata_entry_model.dart";

const Object _unset = Object();

class KhataState {
  final bool isLoading;
  final List<KhataEntryModel> entries;
  final String? error;
  final String? message;

  const KhataState({
    this.isLoading = false,
    this.entries = const [],
    this.error,
    this.message,
  });

  KhataState copyWith({
    bool? isLoading,
    List<KhataEntryModel>? entries,
    Object? error = _unset,
    Object? message = _unset,
  }) {
    return KhataState(
      isLoading: isLoading ?? this.isLoading,
      entries: entries ?? this.entries,
      error: error == _unset ? this.error : error as String?,
      message: message == _unset ? this.message : message as String?,
    );
  }
}