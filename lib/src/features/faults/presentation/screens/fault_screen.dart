import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";

import "../../../telemetry/presentation/providers/telemetry_providers.dart";

class FaultScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const FaultScreen({
    super.key,
    required this.deviceId,
  });

  @override
  ConsumerState<FaultScreen> createState() => _FaultScreenState();
}

class _FaultScreenState extends ConsumerState<FaultScreen> {
  Timer? _refreshTimer;
  bool _firstLoadDone = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await _loadFault();
      _startAutoRefresh();
    });
  }

  Future<void> _loadFault() async {
    await ref
        .read(telemetryViewModelProvider.notifier)
        .loadLatest(widget.deviceId);

    if (mounted) {
      setState(() {
        _firstLoadDone = true;
      });
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) async {
        if (!mounted) return;

        await ref
            .read(telemetryViewModelProvider.notifier)
            .loadLatest(widget.deviceId);
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telemetryState = ref.watch(telemetryViewModelProvider);
    final latest = telemetryState.latest;

    final int activeFaultCode = latest?.faultCode ?? latest?.fault ?? 0;
    final bool hasFault = activeFaultCode != 0;

    final FaultInfo activeFault = FaultData.getByCode(activeFaultCode);

    final bool showInitialLoader = !_firstLoadDone && latest == null;

    return Scaffold(
      backgroundColor: AppColors.darkBgSoft,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: const Text(
          "Fault Monitor",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: showInitialLoader
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
          : ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _FaultHeaderCard(
              key: ValueKey(activeFaultCode),
              hasFault: hasFault,
              fault: activeFault,
              deviceId: widget.deviceId,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Fault Code Reference",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...FaultData.all.map(
                (fault) => _FaultTile(
              fault: fault,
              isActive: fault.code == activeFaultCode,
              hasFault: hasFault,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaultHeaderCard extends StatelessWidget {
  final bool hasFault;
  final FaultInfo fault;
  final String deviceId;

  const _FaultHeaderCard({
    super.key,
    required this.hasFault,
    required this.fault,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = hasFault ? AppColors.fault : AppColors.deviceOnline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCardSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withOpacity(0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasFault
                      ? Icons.warning_rounded
                      : Icons.check_circle_rounded,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasFault ? "Active Fault Detected" : "No Fault",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasFault
                          ? "Code ${fault.code} • ${fault.name}"
                          : "Drive operating normally",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoRow(
            label: "Device",
            value: deviceId,
          ),
          _InfoRow(
            label: "Status",
            value: hasFault ? "Fault Detected" : "Healthy",
          ),
          _InfoRow(
            label: "Fault Code",
            value: fault.code.toString(),
          ),
          _InfoRow(
            label: "Fault",
            value: fault.name,
          ),
          _InfoRow(
            label: "Description",
            value: fault.description,
          ),
        ],
      ),
    );
  }
}

class _FaultTile extends StatelessWidget {
  final FaultInfo fault;
  final bool isActive;
  final bool hasFault;

  const _FaultTile({
    required this.fault,
    required this.isActive,
    required this.hasFault,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isActive
        ? hasFault
        ? AppColors.fault
        : AppColors.deviceOnline
        : AppColors.textMutedSoft;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.12) : AppColors.darkSurfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color.withOpacity(0.9) : AppColors.darkBorderSoft,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              fault.code.toString().padLeft(2, "0"),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fault.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fault.description,
                  style: const TextStyle(
                    color: AppColors.textMutedSoft,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isActive ? Icons.radio_button_checked : Icons.radio_button_off,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMutedSoft,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FaultInfo {
  final int code;
  final String name;
  final String description;

  const FaultInfo({
    required this.code,
    required this.name,
    required this.description,
  });
}

class FaultData {
  static const List<FaultInfo> all = [
    FaultInfo(code: 0, name: "No Fault", description: "Drive operating normally"),
    FaultInfo(code: 1, name: "OUT1", description: "Output phase fault"),
    FaultInfo(code: 2, name: "OUT2", description: "Output abnormality"),
    FaultInfo(code: 3, name: "OUT3", description: "Output phase imbalance"),
    FaultInfo(code: 4, name: "OC1", description: "Acceleration overcurrent"),
    FaultInfo(code: 5, name: "OC2", description: "Deceleration overcurrent"),
    FaultInfo(code: 6, name: "OC3", description: "Constant speed overcurrent"),
    FaultInfo(code: 7, name: "OV1", description: "Acceleration overvoltage"),
    FaultInfo(code: 8, name: "OV2", description: "Deceleration overvoltage"),
    FaultInfo(code: 9, name: "OV3", description: "Constant overvoltage"),
    FaultInfo(code: 10, name: "UV", description: "Under voltage"),
    FaultInfo(code: 11, name: "OL1", description: "Motor overload"),
    FaultInfo(code: 12, name: "OL2", description: "Drive overload"),
    FaultInfo(code: 13, name: "SPI", description: "Internal communication fault"),
    FaultInfo(code: 14, name: "SPO", description: "Output protection triggered"),
    FaultInfo(code: 15, name: "OH1", description: "Drive overheat"),
    FaultInfo(code: 16, name: "OH2", description: "Motor overheat"),
    FaultInfo(code: 17, name: "EF", description: "External fault"),
    FaultInfo(code: 18, name: "CE", description: "Communication error"),
    FaultInfo(code: 19, name: "ItE", description: "Current detection error"),
    FaultInfo(code: 20, name: "tE", description: "Temperature sensor error"),
    FaultInfo(code: 21, name: "EEP", description: "EEPROM memory error"),
    FaultInfo(code: 22, name: "PIDE", description: "PID control error"),
    FaultInfo(code: 23, name: "bCE", description: "Brake circuit error"),
    FaultInfo(code: 24, name: "END", description: "End limit protection"),
    FaultInfo(code: 25, name: "OL3", description: "Severe overload condition"),
  ];

  static FaultInfo getByCode(int code) {
    return all.firstWhere(
          (fault) => fault.code == code,
      orElse: () => FaultInfo(
        code: code,
        name: "Unknown Fault",
        description: "This fault code is not available in fault reference",
      ),
    );
  }
}