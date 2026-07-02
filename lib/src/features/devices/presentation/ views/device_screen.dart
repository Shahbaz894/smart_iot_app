
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/devices/presentation/state/device_state.dart";

import "../../../../app/routes.dart";
import "../../../auth/ presentation/providers/auth_providers.dart";

class DeviceScreen extends ConsumerStatefulWidget {
  const DeviceScreen({super.key});

  @override
  ConsumerState<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends ConsumerState<DeviceScreen> {
  bool _handledNoDeviceNavigation = false;
  bool _loadStarted = false;

  @override
  void initState() {
    super.initState();

    Future(() async {
      if (!mounted) return;

      _loadStarted = true;

      await ref
          .read(deviceSelectionViewModelProvider.notifier)
          .loadDevices();
    });
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
    _handledNoDeviceNavigation = false;
    _loadStarted = true;

    await ref
        .read(deviceSelectionViewModelProvider.notifier)
        .loadDevices();
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

  void _handleNoDeviceFound(DeviceSelectionState state) {
    if (_handledNoDeviceNavigation) return;
    if (!_loadStarted) return;
    if (state.isLoading) return;
    if (state.error != null) return;
    if (state.devices.isNotEmpty) return;

    _handledNoDeviceNavigation = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      _showSnack(
        "No device found. Opening dashboard in safe mode.",
        false,
      );

      await Future<void>.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      _openHomeWithoutDevice();
    });
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

    _handleNoDeviceFound(state);

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 760;

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
        //   IconButton(
        //     tooltip: "Refresh",
        //     onPressed: state.isLoading ? null : _refreshDevices,
        //     icon: const Icon(
        //       Icons.refresh_rounded,
        //       color: AppColors.white,
        //     ),
        //   ),
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
                        onOpenDashboard: _openHomeWithoutDevice,
                        onRefresh: state.isLoading ? null : _refreshDevices,
                      )
                    else
                      _DeviceListSection(
                        state: state,
                        onSelectDevice: (device) async {
                          final selectedDeviceId = await ref
                              .read(
                            deviceSelectionViewModelProvider.notifier,
                          )
                              .selectDevice(device);

                          if (!context.mounted) return;

                          if (selectedDeviceId == null ||
                              selectedDeviceId.trim().isEmpty) {
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
                        },
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
  final Future<void> Function(dynamic device) onSelectDevice;

  const _DeviceListSection({
    required this.state,
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

            return SizedBox(
              width: itemWidth,
              child: _DeviceCard(
                title: device.displayName,
                deviceId: device.primaryDeviceId,
                location: device.location,
                isOnline: device.isOnline,
                isSelected: selected,
                onTap: () => onSelectDevice(device),
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

  const _HeaderCard({
    required this.totalDevices,
  });

  @override
  Widget build(BuildContext context) {
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
                  "$totalDevices device${totalDevices == 1 ? "" : "s"} available",
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
  final bool isOnline;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeviceCard({
    required this.title,
    required this.deviceId,
    required this.location,
    required this.isOnline,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isOnline ? AppColors.green : AppColors.warning;

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
                  isOnline ? "Online" : "Offline",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
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
  final VoidCallback onOpenDashboard;
  final Future<void> Function()? onRefresh;

  const _EmptyDeviceCard({
    required this.onOpenDashboard,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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
            "No device is linked with this account. You can still open the dashboard safely. Readings will stay empty until a device is connected.",
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