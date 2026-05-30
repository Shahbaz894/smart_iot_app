import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:smart_iot_app/src/core/constant/app_color.dart";

class SmartWellHomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool hasDevice;
  final String displayName;
  final String? deviceId;
  final VoidCallback onSelectDevice;

  const SmartWellHomeAppBar({
    super.key,
    required this.hasDevice,
    required this.displayName,
    this.deviceId,
    required this.onSelectDevice,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SmartWellHomeAppBar> createState() => _SmartWellHomeAppBarState();
}

class _SmartWellHomeAppBarState extends State<SmartWellHomeAppBar>
    with WidgetsBindingObserver {
  String _visibleTitle = "AabNex IoT";
  int _loadVersion = 0;

  String get _safeDeviceId => widget.deviceId?.trim() ?? "";

  String get _fallbackTitle {
    final title = widget.displayName.trim();

    if (title.isNotEmpty && title.toLowerCase() != "null") {
      return title;
    }

    if (widget.hasDevice) {
      return "Selected Device";
    }

    return "AabNex IoT";
  }

  String _deviceNameKey(String deviceId) {
    return "custom_device_name_${deviceId.trim()}";
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _visibleTitle = _fallbackTitle;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomDeviceName();
    });
  }

  @override
  void didUpdateWidget(covariant SmartWellHomeAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldDeviceId = oldWidget.deviceId?.trim() ?? "";
    final newDeviceId = widget.deviceId?.trim() ?? "";

    if (oldDeviceId != newDeviceId ||
        oldWidget.displayName != widget.displayName) {
      _visibleTitle = _fallbackTitle;
      _loadCustomDeviceName();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCustomDeviceName();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadCustomDeviceName() async {
    final currentLoad = ++_loadVersion;
    final safeId = _safeDeviceId;

    if (safeId.isEmpty) {
      if (!mounted || currentLoad != _loadVersion) return;

      setState(() {
        _visibleTitle = _fallbackTitle;
      });

      return;
    }

    final prefs = await SharedPreferences.getInstance();

    String? savedName = prefs.getString(_deviceNameKey(safeId))?.trim();

    savedName ??= prefs.getString("device_name_$safeId")?.trim();
    savedName ??= prefs.getString(safeId)?.trim();

    if (!mounted || currentLoad != _loadVersion) return;

    setState(() {
      if (savedName != null && savedName.isNotEmpty) {
        _visibleTitle = savedName;
      } else {
        _visibleTitle = _fallbackTitle;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;

    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: widget.hasDevice,
      iconTheme: const IconThemeData(color: AppColors.white),
      titleSpacing: isSmall ? 8 : 12,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: isSmall ? 36 : 40,
              width: isSmall ? 36 : 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkBgSoft,
                    AppColors.darkBgSoft.withOpacity(0.72),
                  ],
                ),
              ),
              child: Icon(
                Icons.electric_bolt_rounded,
                color: AppColors.white,
                size: isSmall ? 20 : 22,
              ),
            ),
            SizedBox(width: isSmall ? 8 : 10),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  _visibleTitle,
                  key: ValueKey(_visibleTitle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: isSmall ? 16 : 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: isSmall ? 6 : 12),
          child: IconButton(
            tooltip: "Select Device",
            onPressed: widget.onSelectDevice,
            icon: Container(
              padding: EdgeInsets.all(isSmall ? 7 : 8),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Icon(
                Icons.devices_other_rounded,
                color: AppColors.primary,
                size: isSmall ? 18 : 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}