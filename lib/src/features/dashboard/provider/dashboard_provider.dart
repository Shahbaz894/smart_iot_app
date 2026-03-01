// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
//
//
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:smart_iot_app/src/features/dashboard/domain/widget_model.dart';
//
// // Simple Device Config Model
// class WidgetConfig {
//   final String id;
//   final String name;
//   final String type; // toggle, slider, gauge, chart, etc.
//
//   WidgetConfig({required this.id, required this.name, required this.type});
// }
//
// // StateNotifier for dashboard widgets
// class DashboardWidgetsNotifier extends StateNotifier<List<IoTWidgetConfig>> {
//   DashboardWidgetsNotifier() : super([]);
//
//   void addWidget(IoTWidgetConfig widget) {
//     state = [...state, widget];
//   }
//
//   void removeWidget(String id) {
//     state = state.where((w) => w.id != id).toList();
//   }
// }
//
// // Provider
// final dashboardWidgetsProvider =
// StateNotifierProvider<DashboardWidgetsNotifier, List<IoTWidgetConfig>>(
//         (ref) => DashboardWidgetsNotifier());
//
//
