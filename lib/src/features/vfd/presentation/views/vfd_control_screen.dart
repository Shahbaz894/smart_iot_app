import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";

import "../providers/vfd_providers.dart";

class VfdControlScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const VfdControlScreen({
    super.key,
    required this.deviceId,
  });

  @override
  ConsumerState<VfdControlScreen> createState() {
    return _VfdControlScreenState();
  }
}

class _VfdControlScreenState extends ConsumerState<VfdControlScreen> {
  final TextEditingController frequencyController = TextEditingController();

  @override
  void dispose() {
    frequencyController.dispose();
    super.dispose();
  }

  void _showMessage({
    required String message,
    required bool success,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _setFrequency() {
    final frequency = double.tryParse(frequencyController.text.trim());

    if (frequency == null) {
      _showMessage(
        message: "Enter a valid frequency value.",
        success: false,
      );
      return;
    }

    if (frequency <= 0) {
      _showMessage(
        message: "Frequency must be greater than 0.",
        success: false,
      );
      return;
    }

    ref.read(vfdViewModelProvider.notifier).setFrequency(
      deviceId: widget.deviceId,
      frequency: frequency,
    );
  }

  void _resetVfd() {
    ref.read(vfdViewModelProvider.notifier).resetVfd(widget.deviceId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vfdViewModelProvider);
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;
    final maxWidth = size.width >= 650 ? 620.0 : double.infinity;

    ref.listen(
      vfdViewModelProvider,
          (previous, next) {
        if (next.error != null && previous?.error != next.error) {
          _showMessage(
            message: next.error!,
            success: false,
          );
        }

        if (next.message != null && previous?.message != next.message) {
          _showMessage(
            message: next.message!,
            success: true,
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.darkBgSoft,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              "VFD CONTROL",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            Text(
              "REFERENCE FREQUENCY",
              style: TextStyle(
                fontSize: 10,
                color: AppColors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusHeader(
                    isLoading: state.isLoading,
                    deviceId: widget.deviceId,
                  ),
                  const SizedBox(height: 22),
                  _buildFrequencyCard(state.isLoading),
                  const SizedBox(height: 18),
                  _buildResetCard(state.isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FREQUENCY SETPOINT",
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Set the target VFD reference frequency for this device.",
            style: TextStyle(
              color: AppColors.gray400,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: frequencyController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: "Reference Frequency",
              suffixText: "Hz",
              labelStyle: const TextStyle(color: AppColors.gray500),
              suffixStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: AppColors.surfaceDark,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.white.withOpacity(0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.white.withOpacity(0.05),
                ),
              ),
            ),
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: isLoading ? null : _setFrequency,
              icon: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.black,
                ),
              )
                  : const Icon(Icons.speed_rounded),
              label: Text(
                isLoading ? "UPDATING FREQUENCY" : "UPDATE FREQUENCY",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.red.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.restart_alt_rounded,
              color: AppColors.red,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "RESET VFD",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Send reset command to the VFD controller.",
                  style: TextStyle(
                    color: AppColors.gray500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isLoading ? null : _resetVfd,
            child: const Text(
              "RESET",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final bool isLoading;
  final String deviceId;

  const _StatusHeader({
    required this.isLoading,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HeaderMetric(
                title: "STATUS",
                value: isLoading ? "BUSY" : "READY",
                icon: isLoading
                    ? Icons.sync_rounded
                    : Icons.check_circle_rounded,
                color: isLoading ? AppColors.primary : AppColors.green,
              ),
              const SizedBox(width: 10),
              _HeaderMetric(
                title: "MODE",
                value: "VFD",
                icon: Icons.tune_rounded,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.memory_rounded,
                  size: 17,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    deviceId.trim().isEmpty
                        ? "Device ID not available"
                        : "DEVICE: $deviceId",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.gray400,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
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

class _HeaderMetric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _HeaderMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.gray500,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}