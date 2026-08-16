// import "package:flutter/material.dart";
// import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:smart_iot_app/src/core/constant/app_color.dart";
// import "package:smart_iot_app/src/features/devices/presentation/state/device_state.dart";
//
// import "../../../../app/routes.dart";
// import "../../../auth/ presentation/providers/auth_providers.dart";
//
// class DeviceScreen extends ConsumerStatefulWidget {
//   const DeviceScreen({super.key});
//
//   @override
//   ConsumerState<DeviceScreen> createState() => _DeviceScreenState();
// }
//
// class _DeviceScreenState extends ConsumerState<DeviceScreen> {
//   bool _loadStarted = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.microtask(() async {
//       if (!mounted) return;
//
//       _loadStarted = true;
//
//       await ref
//           .read(deviceSelectionViewModelProvider.notifier)
//           .loadDevices();
//     });
//   }
//
//   void _showSnack(String message, bool isError) {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context)
//       ..clearSnackBars()
//       ..showSnackBar(
//         SnackBar(
//           duration: Duration(seconds: isError ? 6 : 4),
//           behavior: SnackBarBehavior.floating,
//           margin: const EdgeInsets.all(16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           backgroundColor: isError ? AppColors.error : AppColors.green,
//           content: Text(
//             message,
//             style: const TextStyle(
//               color: AppColors.white,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ),
//       );
//   }
//
//   Future<void> _refreshDevices() async {
//     _loadStarted = true;
//
//     await ref
//         .read(deviceSelectionViewModelProvider.notifier)
//         .loadDevices();
//   }
//
//   Future<void> _logout() async {
//     await ref.read(deviceSelectionViewModelProvider.notifier).logout();
//
//     if (!mounted) return;
//
//     Navigator.pushNamedAndRemoveUntil(
//       context,
//       AppRoutes.login,
//           (route) => false,
//     );
//   }
//
//   void _openHomeWithoutDevice() {
//     if (!mounted) return;
//
//     Navigator.pushReplacementNamed(
//       context,
//       AppRoutes.home,
//       arguments: const {
//         "deviceId": null,
//         "deviceName": null,
//         "noDeviceMode": true,
//       },
//     );
//   }
//
//   Future<void> _selectDevice(dynamic device) async {
//     final selectedDeviceId = await ref
//         .read(deviceSelectionViewModelProvider.notifier)
//         .selectDevice(device);
//
//     if (!mounted) return;
//
//     if (selectedDeviceId == null || selectedDeviceId.trim().isEmpty) {
//       _showSnack(
//         "Device selection failed. Opening dashboard in safe mode.",
//         true,
//       );
//
//       Navigator.pushReplacementNamed(
//         context,
//         AppRoutes.home,
//         arguments: const {
//           "deviceId": null,
//           "deviceName": null,
//           "noDeviceMode": true,
//         },
//       );
//       return;
//     }
//
//     Navigator.pushReplacementNamed(
//       context,
//       AppRoutes.home,
//       arguments: {
//         "deviceId": selectedDeviceId,
//         "deviceName": device.displayName,
//         "noDeviceMode": false,
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen<DeviceSelectionState>(
//       deviceSelectionViewModelProvider,
//           (previous, next) {
//         if (next.error != null && previous?.error != next.error) {
//           _showSnack(next.error!, true);
//         }
//
//         if (next.message != null && previous?.message != next.message) {
//           _showSnack(next.message!, false);
//         }
//       },
//     );
//
//     final state = ref.watch(deviceSelectionViewModelProvider);
//
//     final width = MediaQuery.of(context).size.width;
//     final isWide = width >= 760;
//
//     return Scaffold(
//       backgroundColor: AppColors.darkBgSoft,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryDark,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           "Select Device",
//           style: TextStyle(
//             color: AppColors.white,
//             fontWeight: FontWeight.w900,
//           ),
//         ),
//         actions: [
//           IconButton(
//             tooltip: "Refresh Devices",
//             onPressed: state.isLoading ? null : _refreshDevices,
//             icon: const Icon(
//               Icons.refresh_rounded,
//               color: AppColors.white,
//             ),
//           ),
//           IconButton(
//             tooltip: "Logout",
//             onPressed: _logout,
//             icon: const Icon(
//               Icons.logout_rounded,
//               color: AppColors.white,
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           color: AppColors.primary,
//           backgroundColor: AppColors.darkSurfaceSoft,
//           onRefresh: _refreshDevices,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(
//               parent: BouncingScrollPhysics(),
//             ),
//             padding: EdgeInsets.symmetric(
//               horizontal: isWide ? 34 : 18,
//               vertical: 22,
//             ),
//             child: Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 960),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _HeaderCard(
//                       totalDevices: state.devices.length,
//                       isLoading: state.isLoading,
//                     ),
//                     const SizedBox(height: 18),
//                     if (state.isLoading && state.devices.isEmpty)
//                       const Padding(
//                         padding: EdgeInsets.all(34),
//                         child: Center(
//                           child: CircularProgressIndicator(
//                             color: AppColors.white,
//                           ),
//                         ),
//                       )
//                     else if (state.devices.isEmpty)
//                       _EmptyDeviceCard(
//                         loadStarted: _loadStarted,
//                         onOpenDashboard: _openHomeWithoutDevice,
//                         onRefresh: state.isLoading ? null : _refreshDevices,
//                       )
//                     else
//                       _DeviceListSection(
//                         state: state,
//                         onSelectDevice: _selectDevice,
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _DeviceListSection extends StatelessWidget {
//   final DeviceSelectionState state;
//   final Future<void> Function(dynamic device) onSelectDevice;
//
//   const _DeviceListSection({
//     required this.state,
//     required this.onSelectDevice,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final twoColumns = constraints.maxWidth >= 720;
//         final itemWidth = twoColumns
//             ? (constraints.maxWidth - 14) / 2
//             : constraints.maxWidth;
//
//         return Wrap(
//           spacing: 14,
//           runSpacing: 14,
//           children: state.devices.map((device) {
//             final selected =
//                 state.selectedDeviceId == device.primaryDeviceId;
//
//             return SizedBox(
//               width: itemWidth,
//               child: _DeviceCard(
//                 title: device.displayName,
//                 deviceId: device.primaryDeviceId,
//                 location: device.location,
//                 isSelected: selected,
//                 onTap: () => onSelectDevice(device),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }
//
// class _HeaderCard extends StatelessWidget {
//   final int totalDevices;
//   final bool isLoading;
//
//   const _HeaderCard({
//     required this.totalDevices,
//     required this.isLoading,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final subtitle = isLoading
//         ? "Checking registered devices..."
//         : "$totalDevices registered device${totalDevices == 1 ? "" : "s"}";
//
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 14,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.borderDark),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.06),
//             blurRadius: 16,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 40,
//             width: 40,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.14),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.devices_other_rounded,
//               color: AppColors.primary,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   "AabNex",
//                   style: TextStyle(
//                     color: AppColors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.65),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isLoading)
//             const SizedBox(
//               height: 18,
//               width: 18,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: AppColors.primary,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// class _DeviceCard extends StatelessWidget {
//   final String title;
//   final String deviceId;
//   final String location;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _DeviceCard({
//     required this.title,
//     required this.deviceId,
//     required this.location,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     const statusColor = AppColors.primary;
//
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(22),
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: AppColors.cardDark,
//           borderRadius: BorderRadius.circular(22),
//           border: Border.all(
//             color: isSelected ? AppColors.primary : AppColors.borderDark,
//             width: isSelected ? 1.5 : 1,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   backgroundColor: AppColors.primary.withOpacity(0.14),
//                   child: const Icon(
//                     Icons.precision_manufacturing_rounded,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     title.trim().isEmpty ? "Unnamed Device" : title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: AppColors.white,
//                       fontSize: 17,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                 ),
//                 if (isSelected)
//                   const Icon(
//                     Icons.check_circle_rounded,
//                     color: AppColors.primary,
//                   ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _InfoLine(
//               icon: Icons.memory_rounded,
//               label: "Device ID",
//               value: deviceId.trim().isEmpty ? "-" : deviceId,
//             ),
//             const SizedBox(height: 8),
//             _InfoLine(
//               icon: Icons.location_on_outlined,
//               label: "Location",
//               value: location.trim().isEmpty ? "-" : location,
//             ),
//             const SizedBox(height: 14),
//             Row(
//               children: [
//
//                 const Spacer(),
//                 Text(
//                   "Tap to open",
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.48),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 const Icon(
//                   Icons.arrow_forward_ios_rounded,
//                   color: Colors.white54,
//                   size: 16,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _InfoLine extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//
//   const _InfoLine({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           color: Colors.white54,
//           size: 18,
//         ),
//         const SizedBox(width: 8),
//         Text(
//           "$label: ",
//           style: TextStyle(
//             color: AppColors.white.withOpacity(0.55),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               color: AppColors.white,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _EmptyDeviceCard extends StatelessWidget {
//   final bool loadStarted;
//   final VoidCallback onOpenDashboard;
//   final Future<void> Function()? onRefresh;
//
//   const _EmptyDeviceCard({
//     required this.loadStarted,
//     required this.onOpenDashboard,
//     required this.onRefresh,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final message = loadStarted
//         ? "No device is linked with this account. You can still open the dashboard safely. Readings will stay empty until a device is connected."
//         : "Checking linked devices...";
//
//     return Container(
//       padding: const EdgeInsets.all(26),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: AppColors.borderDark),
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 76,
//             width: 76,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.12),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.dashboard_customize_rounded,
//               color: AppColors.primary,
//               size: 42,
//             ),
//           ),
//           const SizedBox(height: 14),
//           const Text(
//             "No devices found",
//             style: TextStyle(
//               color: AppColors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           const SizedBox(height: 7),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.65),
//               fontWeight: FontWeight.w600,
//               height: 1.35,
//             ),
//           ),
//           const SizedBox(height: 22),
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: ElevatedButton.icon(
//               onPressed: onOpenDashboard,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: AppColors.black,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               icon: const Icon(Icons.monitor_heart_rounded),
//               label: const Text(
//                 "Open Dashboard",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: OutlinedButton.icon(
//               onPressed: onRefresh,
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: AppColors.primary,
//                 side: const BorderSide(color: AppColors.primary),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text(
//                 "Check Again",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/devices/presentation/state/device_state.dart";

import "../../../../app/routes.dart";
import "../../../auth/ presentation/providers/auth_providers.dart";
import "../../../telemetry/presentation/providers/telemetry_providers.dart";

class DeviceScreen extends ConsumerStatefulWidget {
  const DeviceScreen({super.key});

  @override
  ConsumerState<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends ConsumerState<DeviceScreen> {
  bool _loadStarted = false;

  // Keeps an independent live status for every registered device.
  // We cannot keep `latest` as a class-level variable because telemetry
  // belongs to the telemetry provider and changes per device.
  final Map<String, bool> _deviceOnlineStatus = <String, bool>{};

  bool _checkingDeviceStatuses = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (!mounted) return;

      _loadStarted = true;

      await ref
          .read(deviceSelectionViewModelProvider.notifier)
          .loadDevices();

      if (!mounted) return;

      await _loadDeviceOnlineStatuses();
    });
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  bool _isDeviceOnline(dynamic latest) {
    if (latest == null) return false;

    final live = _toInt(latest.isLive) == 1;
    final fresh = latest.isFresh(withinSeconds: 20);

    return live && fresh;
  }

  Future<void> _loadDeviceOnlineStatuses() async {
    if (_checkingDeviceStatuses) return;

    final devices = ref.read(deviceSelectionViewModelProvider).devices;

    if (devices.isEmpty) {
      if (mounted) {
        setState(() {
          _deviceOnlineStatus.clear();
        });
      } else {
        _deviceOnlineStatus.clear();
      }
      return;
    }

    _checkingDeviceStatuses = true;

    if (mounted) {
      setState(() {});
    }

    try {
      for (final device in devices) {
        if (!mounted) return;

        final deviceId = device.primaryDeviceId.toString().trim();

        if (deviceId.isEmpty) {
          _deviceOnlineStatus[deviceId] = false;
          continue;
        }

        try {
          await ref
              .read(telemetryViewModelProvider.notifier)
              .loadLatest(
            deviceId,
            showLoading: false,
          );

          if (!mounted) return;

          final latest = ref.read(telemetryViewModelProvider).latest;

          _deviceOnlineStatus[deviceId] = _isDeviceOnline(latest);
        } catch (_) {
          _deviceOnlineStatus[deviceId] = false;
        }

        if (mounted) {
          setState(() {});
        }
      }
    } finally {
      _checkingDeviceStatuses = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _showSnack(String message, bool isError) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: isError ? 6 : 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: isError ? AppColors.error : AppColors.green,
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
  }

  Future<void> _refreshDevices() async {
    _loadStarted = true;

    await ref
        .read(deviceSelectionViewModelProvider.notifier)
        .loadDevices();

    if (!mounted) return;

    await _loadDeviceOnlineStatuses();
  }

  Future<void> _logout() async {
    await ref.read(deviceSelectionViewModelProvider.notifier).logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }

  void _openHomeWithoutDevice() {
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
      arguments: const {
        "deviceId": null,
        "deviceName": null,
        "noDeviceMode": true,
      },
    );
  }

  Future<void> _selectDevice(dynamic device) async {
    final selectedDeviceId = await ref
        .read(deviceSelectionViewModelProvider.notifier)
        .selectDevice(device);

    if (!mounted) return;

    if (selectedDeviceId == null || selectedDeviceId.trim().isEmpty) {
      _showSnack(
        "Device selection failed. Opening dashboard in safe mode.",
        true,
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: const {
          "deviceId": null,
          "deviceName": null,
          "noDeviceMode": true,
        },
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
      arguments: {
        "deviceId": selectedDeviceId,
        "deviceName": device.displayName,
        "noDeviceMode": false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DeviceSelectionState>(
      deviceSelectionViewModelProvider,
          (previous, next) {
        if (next.error != null && previous?.error != next.error) {
          _showSnack(next.error!, true);
        }

        if (next.message != null && previous?.message != next.message) {
          _showSnack(next.message!, false);
        }
      },
    );

    final state = ref.watch(deviceSelectionViewModelProvider);

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 760;

    final onlineDevices = state.devices.where((device) {
      final id = device.primaryDeviceId.toString().trim();
      return _deviceOnlineStatus[id] ?? false;
    }).length;

    final offlineDevices = state.devices.length - onlineDevices;

    return Scaffold(
      backgroundColor: AppColors.darkBgSoft,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Select Device",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Refresh Devices",
            onPressed:
            state.isLoading || _checkingDeviceStatuses
                ? null
                : _refreshDevices,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.white,
            ),
          ),
          IconButton(
            tooltip: "Logout",
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.darkSurfaceSoft,
          onRefresh: _refreshDevices,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 34 : 18,
              vertical: 22,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderCard(
                      totalDevices: state.devices.length,
                      onlineDevices: onlineDevices,
                      offlineDevices: offlineDevices,
                      isLoading: state.isLoading,
                      isCheckingStatus: _checkingDeviceStatuses,
                    ),
                    const SizedBox(height: 18),
                    if (state.isLoading && state.devices.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(34),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                        ),
                      )
                    else if (state.devices.isEmpty)
                      _EmptyDeviceCard(
                        loadStarted: _loadStarted,
                        onOpenDashboard: _openHomeWithoutDevice,
                        onRefresh:
                        state.isLoading || _checkingDeviceStatuses
                            ? null
                            : _refreshDevices,
                      )
                    else
                      _DeviceListSection(
                        state: state,
                        onlineStatus: _deviceOnlineStatus,
                        onSelectDevice: _selectDevice,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeviceListSection extends StatelessWidget {
  final DeviceSelectionState state;
  final Map<String, bool> onlineStatus;
  final Future<void> Function(dynamic device) onSelectDevice;

  const _DeviceListSection({
    required this.state,
    required this.onlineStatus,
    required this.onSelectDevice,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 720;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - 14) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: state.devices.map((device) {
            final selected =
                state.selectedDeviceId == device.primaryDeviceId;

            final id = device.primaryDeviceId.toString().trim();
            final isOnline = onlineStatus[id] ?? false;

            return SizedBox(
              width: itemWidth,
              child: _DeviceCard(
                title: device.displayName,
                deviceId: device.primaryDeviceId,
                location: device.location,
                isSelected: selected,
                onTap: () => onSelectDevice(device),
                isOnline: isOnline,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int totalDevices;
  final int onlineDevices;
  final int offlineDevices;
  final bool isLoading;
  final bool isCheckingStatus;

  const _HeaderCard({
    required this.totalDevices,
    required this.onlineDevices,
    required this.offlineDevices,
    required this.isLoading,
    required this.isCheckingStatus,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = isLoading
        ? "Checking registered devices..."
        : isCheckingStatus
        ? "Checking device connection status..."
        : totalDevices == 0
        ? "No device connected"
        : "$onlineDevices online • $offlineDevices offline";

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.devices_other_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "AabNex",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading || isCheckingStatus)
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final String title;
  final String deviceId;
  final String location;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isOnline;

  const _DeviceCard({
    required this.title,
    required this.deviceId,
    required this.location,
    required this.isSelected,
    required this.onTap,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
    isOnline ? AppColors.green : AppColors.warning;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.14),
                  child: const Icon(
                    Icons.precision_manufacturing_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title.trim().isEmpty ? "Unnamed Device" : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoLine(
              icon: Icons.memory_rounded,
              label: "Device ID",
              value: deviceId.trim().isEmpty ? "-" : deviceId,
            ),
            const SizedBox(height: 8),
            _InfoLine(
              icon: Icons.location_on_outlined,
              label: "Location",
              value: location.trim().isEmpty ? "-" : location,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: statusColor,
                  size: 12,
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? "Device Online" : "Device Offline",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  "Tap to open",
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.48),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white54,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            color: AppColors.white.withOpacity(0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyDeviceCard extends StatelessWidget {
  final bool loadStarted;
  final VoidCallback onOpenDashboard;
  final Future<void> Function()? onRefresh;

  const _EmptyDeviceCard({
    required this.loadStarted,
    required this.onOpenDashboard,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final message = loadStarted
        ? "No device is linked with this account. You can still open the dashboard safely. Readings will stay empty until a device is connected."
        : "Checking linked devices...";

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dashboard_customize_rounded,
              color: AppColors.primary,
              size: 42,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "No devices found",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.65),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onOpenDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.monitor_heart_rounded),
              label: const Text(
                "Open Dashboard",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                "Check Again",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
