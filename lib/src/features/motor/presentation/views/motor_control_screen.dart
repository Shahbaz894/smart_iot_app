import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../ providers/motor_providers.dart";


class MotorControlScreen extends ConsumerWidget {
  final String deviceId;
  final String customerName;

  const MotorControlScreen({
    super.key,
    required this.deviceId,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(motorViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Motor Control")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (state.isLoading) const CircularProgressIndicator(),
            if (state.error != null) Text(state.error!),
            if (state.message != null) Text(state.message!),
            ElevatedButton(
              onPressed: () {
                ref.read(motorViewModelProvider.notifier).startMotor(
                  deviceId: deviceId,
                  customerName: customerName,
                );
              },
              child: const Text("Start Motor"),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(motorViewModelProvider.notifier).stopMotor(
                  deviceId: deviceId,
                  customerName: customerName,
                );
              },
              child: const Text("Stop Motor"),
            ),
          ],
        ),
      ),
    );
  }
}