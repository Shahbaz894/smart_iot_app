import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/widget/connection_badges.dart";
import "package:smart_iot_app/src/features/widget/vfd_header_card.dart";

import "customer_name_field.dart";
import "motor_button.dart";
import "telemetry_metrics_grid.dart";
import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";

class HomeDashboardContent extends StatelessWidget {
  final bool hasDevice;
  final String? deviceId;
  final String displayName;
  final dynamic latest;
  final dynamic telemetryState;
  final dynamic motorState;
  final MotorSnapshot snapshot;
  final DeviceConnectionStatus status;
  final Animation<double> pulseAnimation;
  final TextEditingController customerNameController;
  final FocusNode customerNameFocusNode;
  final List<String> customerSuggestions;
  final String runningTime;
  final double horizontalPadding;
  final int crossAxisCount;
  final double childAspectRatio;
  final double buttonSize;
  final bool isVerySmall;
  final Future<void> Function() onRefresh;
  final VoidCallback onMotorTap;
  final String Function(
      double? value,
      String unit, {
      int decimals,
      required DeviceConnectionStatus status,
      }) formatValue;

  const HomeDashboardContent({
    super.key,
    required this.hasDevice,
    required this.deviceId,
    required this.displayName,
    required this.latest,
    required this.telemetryState,
    required this.motorState,
    required this.snapshot,
    required this.status,
    required this.pulseAnimation,
    required this.customerNameController,
    required this.customerNameFocusNode,
    required this.customerSuggestions,
    required this.runningTime,
    required this.horizontalPadding,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.buttonSize,
    required this.isVerySmall,
    required this.onRefresh,
    required this.onMotorTap,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "🟤 DASHBOARD SNAPSHOT => running=${snapshot.isRunning} status=${snapshot.connectionStatus}",
    );

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceDark,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 18,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VfdHeaderCard(
                    key: ValueKey(
                      "header_${snapshot.isRunning}_${snapshot.connectionStatus}",
                    ),
                    displayName: displayName,
                    snapshot: snapshot,
                    frequencyText: formatValue(
                      latest?.freq,
                      "Hz",
                      decimals: 1,
                      status: status,
                    ),
                    referenceFrequencyText: formatValue(
                      latest?.referenceFreq ?? latest?.freq,
                      "Hz",
                      decimals: 1,
                      status: status,
                    ),
                  ),

                  if (status == DeviceConnectionStatus.noDevice)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: DeviceNotConnectedBadge(),
                    ),

                  if (status == DeviceConnectionStatus.waitingTelemetry)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: WaitingTelemetryBadge(),
                    ),

                  if (status == DeviceConnectionStatus.disconnected)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: DeviceDisconnectedBadge(),
                    ),

                  const SizedBox(height: 18),

                  CustomerNameField(
                    controller: customerNameController,
                    focusNode: customerNameFocusNode,
                    suggestions: customerSuggestions,
                    enabled: hasDevice,
                  ),

                  const SizedBox(height: 26),

                  Center(
                    child: AnimatedBuilder(
                      animation: pulseAnimation,
                      builder: (context, _) {
                        final scale = snapshot.isRunning
                            ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
                            : 1.0;

                        return Transform.scale(
                          scale: scale,
                          child: MotorButton(
                            key: ValueKey(
                              "motor_button_${snapshot.isRunning}_${snapshot.connectionStatus}_${motorState.isLoading}",
                            ),
                            snapshot: snapshot,
                            loading: hasDevice && motorState.isLoading,
                            size: buttonSize,
                            onTap: onMotorTap,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        snapshot.isRunning
                            ? "Running | $runningTime"
                            : snapshot.centerStatusText,
                        key: ValueKey(
                          "status_text_${snapshot.isRunning}_${snapshot.centerStatusText}_$runningTime",
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.76),
                          fontSize: isVerySmall ? 14 : 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  if (hasDevice && telemetryState.isLoading && latest == null)
                    const Padding(
                      padding: EdgeInsets.all(22),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  TelemetryMetricsGrid(
                    latest: latest,
                    status: status,
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    formatValue: formatValue,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}