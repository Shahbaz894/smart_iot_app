import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";
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
  ProviderSubscription<DeviceSelectionState>? _deviceStateSubscription;

  bool _isNavigating = false;
  bool _initialLoadDone = false;

  // Local storage cache map to override names coming from the database
  final Map<String, String> _customDeviceNames = {};

  String _deviceNameKey(String deviceId) {
    return "custom_device_name_${deviceId.trim()}";
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      _deviceStateSubscription = ref.listenManual<DeviceSelectionState>(
        deviceSelectionViewModelProvider,
        _onDeviceStateChanged,
      );
      _initialLoad();
    });
  }

  @override
  void dispose() {
    _deviceStateSubscription?.close();
    super.dispose();
  }

  Future<void> _initialLoad() async {
    if (!mounted) return;
    await ref.read(deviceSelectionViewModelProvider.notifier).loadDevices();
    if (!mounted) return;
    await _loadSavedDeviceNames();
    if (!mounted) return;
    setState(() {
      _initialLoadDone = true;
    });
  }

  void _onDeviceStateChanged(
      DeviceSelectionState? previous,
      DeviceSelectionState next,
      ) {
    if (!mounted || _isNavigating) return;

    if (next.error != null && previous?.error != next.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _isNavigating) return;
        _showSnack(next.error!, true);
      });
    }

    if (next.message != null && previous?.message != next.message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _isNavigating) return;
        _showSnack(next.message!, false);
      });
    }

    if (previous?.devices.length != next.devices.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || _isNavigating) return;
        await _loadSavedDeviceNames();
      });
    }
  }

  // Reads saved string data from local SharedPreferences memory
  Future<void> _loadSavedDeviceNames() async {
    final prefs = await SharedPreferences.getInstance();
    final state = ref.read(deviceSelectionViewModelProvider);
    final Map<String, String> names = {};

    for (final device in state.devices) {
      final deviceId = device.primaryDeviceId.toString().trim();
      if (deviceId.isEmpty) continue;

      final savedName = prefs.getString(_deviceNameKey(deviceId))?.trim();
      if (savedName != null && savedName.isNotEmpty) {
        names[deviceId] = savedName;
      }
    }

    if (!mounted) return;
    setState(() {
      _customDeviceNames
        ..clear()
        ..addAll(names);
    });
  }

  // Modifies shared preference files and local maps cleanly
  Future<void> _saveDeviceName({
    required String deviceId,
    required String name,
  }) async {
    final safeDeviceId = deviceId.trim();
    final safeName = name.trim();

    if (safeDeviceId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();

    if (safeName.isEmpty) {
      await prefs.remove(_deviceNameKey(safeDeviceId));
      if (!mounted) return;
      setState(() {
        _customDeviceNames.remove(safeDeviceId);
      });
      _showSnack("Device name reset to database default.", false);
      return;
    }

    await prefs.setString(_deviceNameKey(safeDeviceId), safeName);
    if (!mounted) return;
    setState(() {
      _customDeviceNames[safeDeviceId] = safeName;
    });
    _showSnack("Device custom name saved locally.", false);
  }
  Future<void> _showEditDeviceNameDialog({
    required String deviceId,
    required String currentName,
  }) async {
    if (_isNavigating) return;

    // FIX: Show dialog and pass a custom StatefulWidget builder so the controller
    // is disposed ONLY after the closing animations finish completely.
    final dialogActionMap = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _DialogContentWrapper(initialName: currentName);
      },
    );

    // Context check guard
    if (!mounted || dialogActionMap == null) return;

    // Wait for the dialog unmounting animation frame sequence to finish completely.
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // Execute storage modifications cleanly inside safe, post-dialog screen scope
    final String action = dialogActionMap["action"] ?? "";
    if (action == "reset") {
      await _saveDeviceName(deviceId: deviceId, name: "");
    } else if (action == "save") {
      final String userValue = dialogActionMap["value"] ?? "";
      await _saveDeviceName(deviceId: deviceId, name: userValue);
    }
  }

  void _showSnack(String message, bool isError) {
    if (!mounted || _isNavigating) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: isError ? 5 : 3),
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
    await ref.read(deviceSelectionViewModelProvider.notifier).loadDevices();
    if (!mounted) return;
    await _loadSavedDeviceNames();
  }

  Future<void> _logout() async {
    if (_isNavigating) return;
    _isNavigating = true;
    await ref.read(deviceSelectionViewModelProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
          (route) => false,
    );
  }

  void _openHomeWithoutDevice() {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
          (route) => false,
      arguments: const {
        "deviceId": null,
        "deviceName": null,
        "noDeviceMode": true,
      },
    );
  }

  void _openHomeWithDevice({
    required String deviceId,
    required String deviceName,
  }) {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
          (route) => false,
      arguments: {
        "deviceId": deviceId,
        "deviceName": deviceName,
        "noDeviceMode": false,
      },
    );
  }

  Future<void> _selectDevice(dynamic device) async {
    if (_isNavigating) return;

    final selectedDeviceId = await ref
        .read(deviceSelectionViewModelProvider.notifier)
        .selectDevice(device);

    if (!mounted || _isNavigating) return;

    if (selectedDeviceId == null || selectedDeviceId.trim().isEmpty) {
      _showSnack(
        "Device selection failed. Opening dashboard safely.",
        true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted || _isNavigating) return;
      _openHomeWithoutDevice();
      return;
    }

    final safeSelectedDeviceId = selectedDeviceId.trim();
    final customName = _customDeviceNames[safeSelectedDeviceId]?.trim();

    // Fallback logic: Use local customName if present, otherwise fallback to database display name
    final finalDeviceName = customName != null && customName.isNotEmpty
        ? customName
        : device.displayName;

    _openHomeWithDevice(
      deviceId: safeSelectedDeviceId,
      deviceName: finalDeviceName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceSelectionViewModelProvider);
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isSmall = width < 380;
    final isTablet = width >= 650;
    final isDesktop = width >= 1024;

    final horizontalPadding = isDesktop
        ? 36.0
        : isTablet
        ? 28.0
        : isSmall
        ? 14.0
        : 18.0;

    return Scaffold(
      backgroundColor: AppColors.darkBgSoft,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Select Device",
          style: TextStyle(
            color: AppColors.white,
            fontSize: isSmall ? 18 : 20,
            fontWeight: FontWeight.w900,
          ),
        ),

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isSmall ? 16 : 22,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(totalDevices: state.devices.length),
                  SizedBox(height: isSmall ? 14 : 18),
                  if (state.isLoading && state.devices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(34),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.white),
                      ),
                    )
                  else if (_initialLoadDone && state.devices.isEmpty)
                    _EmptyDeviceCard(
                      onOpenDashboard: _openHomeWithoutDevice,
                      onRefresh: state.isLoading ? null : _refreshDevices,
                    )
                  else
                    _DeviceListSection(
                      state: state,
                      customDeviceNames: _customDeviceNames,
                      onRenameDevice: ({
                        required String deviceId,
                        required String currentName,
                      }) {
                        _showEditDeviceNameDialog(
                          deviceId: deviceId,
                          currentName: currentName,
                        );
                      },
                      onSelectDevice: _selectDevice,
                    ),
                ],
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
  final Map<String, String> customDeviceNames;
  final Future<void> Function(dynamic device) onSelectDevice;
  final void Function({
  required String deviceId,
  required String currentName,
  }) onRenameDevice;

  const _DeviceListSection({
    required this.state,
    required this.customDeviceNames,
    required this.onSelectDevice,
    required this.onRenameDevice,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final crossAxisCount = maxWidth >= 980
            ? 3
            : maxWidth >= 650
            ? 2
            : 1;

        final spacing = width < 380 ? 10.0 : 14.0;
        final itemWidth = crossAxisCount == 1
            ? maxWidth
            : (maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: state.devices.map((device) {
            final deviceId = device.primaryDeviceId.toString().trim();
            final selected = state.selectedDeviceId == device.primaryDeviceId;

            final savedName = customDeviceNames[deviceId]?.trim();
            final displayTitle = savedName != null && savedName.isNotEmpty
                ? savedName
                : device.displayName;

            // Use backend/device model status only.
            // Do NOT force offline from updatedAt here because updatedAt is not
            // always a live heartbeat timestamp.
            final bool verifiedOnlineStatus = device.isOnline ?? false;

            return SizedBox(
              width: itemWidth,
              child:
              _DeviceCard(
                title: displayTitle,
                originalTitle: device.displayName,
                deviceId: device.primaryDeviceId,
                location: device.location,
                isOnline: verifiedOnlineStatus,
                isSelected: selected,
                hasCustomName: savedName != null && savedName.isNotEmpty,
                onTap: () => onSelectDevice(device),
                onEditName: () => onRenameDevice(
                  deviceId: deviceId,
                  currentName: displayTitle,
                ),
              )
            );
          }).toList(),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int totalDevices;
  const _HeaderCard({required this.totalDevices});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 14 : 16,
        vertical: isSmall ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            height: isSmall ? 38 : 40,
            width: isSmall ? 38 : 40,
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
          const Expanded(
            child: Text(
              "Your Devices",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// This extracted widget guarantees the lifecycle of the TextEditingController matches the dialog layout view
class _DialogContentWrapper extends StatefulWidget {
  final String initialName;
  const _DialogContentWrapper({required this.initialName});

  @override
  State<_DialogContentWrapper> createState() => _DialogContentWrapperState();
}

class _DialogContentWrapperState extends State<_DialogContentWrapper> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName.trim());
  }

  @override
  void dispose() {
    // This now fires safely AFTER the pop animation finishes completely
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isSmall = width < 380;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16 : 28,
        vertical: 24,
      ),
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      title: Text(
        "Edit Device Name",
        style: TextStyle(
          color: AppColors.white,
          fontSize: isSmall ? 18 : 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SizedBox(
        width: width > 520 ? 420 : width,
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLength: 32,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            counterStyle: TextStyle(
              color: AppColors.white.withOpacity(0.55),
            ),
            hintText: "Example: Home Motor, Farm Well 1",
            hintStyle: TextStyle(
              color: AppColors.white.withOpacity(0.45),
            ),
            filled: true,
            fillColor: AppColors.darkSurfaceSoft,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.white.withOpacity(0.10),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({"action": "reset"});
          },
          child: const Text(
            "Reset",
            style: TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: AppColors.white.withOpacity(0.70),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              "action": "save",
              "value": _controller.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Save",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}


class _DeviceCard extends StatelessWidget {
  final String title;
  final String originalTitle;
  final String deviceId;
  final String location;
  final bool isOnline; // Yeh ab timestamp logic se decide hoke aayega
  final bool isSelected;
  final bool hasCustomName;
  final VoidCallback onTap;
  final VoidCallback onEditName;

  const _DeviceCard({
    required this.title,
    required this.originalTitle,
    required this.deviceId,
    required this.location,
    required this.isOnline,
    required this.isSelected,
    required this.hasCustomName,
    required this.onTap,
    required this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;

    // 🎨 Offline aur Disconnected dono surto mein purely WARNING/OFFLINE color show hoga
    final statusColor = isOnline ? AppColors.green : AppColors.warning;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 14 : 18),
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
                    radius: isSmall ? 18 : 20,
                    backgroundColor: AppColors.primary.withOpacity(0.14),
                    child: const Icon(
                      Icons.precision_manufacturing_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: isSmall ? 9 : 12),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        title,
                        key: ValueKey(title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: isSmall ? 15 : 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onEditName,
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: 21,
                    ),
                  ),
                ],
              ),
              if (hasCustomName) ...[
                const SizedBox(height: 4),
                Text(
                  "DB Name: $originalTitle",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.45),
                    fontSize: isSmall ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              SizedBox(height: isSmall ? 12 : 16),
              _InfoLine(icon: Icons.memory_rounded, label: "Device ID", value: deviceId),
              const SizedBox(height: 8),
              _InfoLine(icon: Icons.location_on_outlined, label: "Location", value: location),
              SizedBox(height: isSmall ? 12 : 14),
              Row(
                children: [
                  Icon(Icons.circle, color: statusColor, size: 12),
                  const SizedBox(width: 8),
                  Text(
                    isOnline ? "Online" : "Offline", // Dono scenarios mein single word standard 'Offline'
                    style: TextStyle(
                      color: statusColor,
                      fontSize: isSmall ? 12.5 : 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: isSmall ? 16 : 18),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            color: AppColors.white.withOpacity(0.55),
            fontSize: isSmall ? 12 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? "-" : value,
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

  const _EmptyDeviceCard({required this.onOpenDashboard, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;

    return Container(
      padding: EdgeInsets.all(isSmall ? 20 : 26),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Container(
            height: isSmall ? 66 : 76,
            width: isSmall ? 66 : 76,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.dashboard_customize_rounded,
              color: AppColors.primary,
              size: isSmall ? 36 : 42,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "No devices found",
            style: TextStyle(
              color: AppColors.white,
              fontSize: isSmall ? 18 : 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: isSmall ? 48 : 52,
            child: ElevatedButton.icon(
              onPressed: onOpenDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.monitor_heart_rounded),
              label: const Text("Open Dashboard", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}