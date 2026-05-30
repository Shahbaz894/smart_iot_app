import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";


import "../../../auth/ presentation/providers/auth_providers.dart";
import "../state/vfd_state.dart";
import "../viewmodels/vfd_viewmodel.dart";



final vfdViewModelProvider =
StateNotifierProvider<VfdViewModel, VfdState>((ref) {
  return VfdViewModel(
    vfdRepository: ref.read(vfdRepositoryProvider),
  );
});