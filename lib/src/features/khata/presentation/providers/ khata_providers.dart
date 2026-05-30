import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";

import "../../../auth/ presentation/providers/auth_providers.dart";

import "../../data/repositories/khata_repository.dart";
import "../../data/services/khata_api_service.dart";
import "../../data/services/khata_pdf_service.dart";
import "../state/khata_state.dart";
import "../viewmodels/khata_viewmodel.dart";

final khataApiServiceProvider = Provider<KhataApiService>((ref) {
  return KhataApiService(
    ref.read(apiClientProvider),
  );
});

final khataPdfServiceProvider = Provider<KhataPdfService>((ref) {
  return KhataPdfService();
});

final khataRepositoryProvider = Provider<KhataRepository>((ref) {
  return KhataRepository(
    ref.read(khataApiServiceProvider),
  );
});

final khataViewModelProvider =
StateNotifierProvider<KhataViewModel, KhataState>((ref) {
  return KhataViewModel(
    khataRepository: ref.read(khataRepositoryProvider),
  );
});