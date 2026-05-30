import "package:flutter/material.dart";
import "package:smart_iot_app/src/features/devices/presentation/state/device_state.dart";
import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";


import "metric_card.dart";
class TelemetryMetricsGrid extends StatelessWidget {
  final dynamic latest;
  final DeviceConnectionStatus status;
  final int crossAxisCount;
  final double childAspectRatio;
  final String Function(
      double? value,
      String unit, {
      int decimals,
      required DeviceConnectionStatus status,
      }) formatValue;

  const TelemetryMetricsGrid({
    super.key,
    required this.latest,
    required this.status,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: childAspectRatio,
      children: [
        MetricCard(
          icon: Icons.sync_rounded,
          title: "Running Frequency",
          value: formatValue(latest?.freq, "Hz", status: status),
          highlight: true,
        ),
        MetricCard(
          icon: Icons.bolt_rounded,
          title: "AC Voltage",
          value: formatValue(latest?.voltage, "V", status: status),
        ),
        MetricCard(
          icon: Icons.flash_on_rounded,
          title: "OutPut Current",
          value: formatValue(latest?.current, "A", status: status),
        ),
        MetricCard(
          icon: Icons.power_rounded,
          title: "Power",
          value: formatValue(latest?.power, "kW", status: status),
        ),
        MetricCard(
          icon: Icons.speed_rounded,
          title: "Torque Load",
          value: formatValue(latest?.powerPercent, "%", status: status),
        ),
        MetricCard(
          icon: Icons.rotate_right_rounded,
          title: "Motor Speed",
          value: formatValue(latest?.motorSpeed, "RPM", status: status),
        ),
        MetricCard(
          icon: Icons.battery_charging_full_rounded,
          title: "Solar DC Voltage",
          value: formatValue(latest?.dcbus, "V", status: status),
        ),
        MetricCard(
          icon: Icons.electric_meter_rounded,
          title: "Energy",
          value: formatValue(latest?.energyIn, "kWh", status: status),
        ),
      ],
    );
  }
}