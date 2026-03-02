
import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';
import 'package:smart_iot_app/src/features/dashboard/model/time_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../provider/time_provider.dart'; // Adjust path

// Change to ConsumerStatefulWidget to access 'ref'
class TimerEditDialog extends ConsumerStatefulWidget {
  final TimerDevice? timer;
  final Set<int> selectedDays;
  const TimerEditDialog({super.key, this.timer,required this.selectedDays});


  @override
  ConsumerState<TimerEditDialog> createState() => _TimerEditDialogState();
}

class _TimerEditDialogState extends ConsumerState<TimerEditDialog> {
  late TimeOfDay start;
  late TimeOfDay stop;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with existing data or defaults
    start = widget.timer?.startTime ?? const TimeOfDay(hour: 8, minute: 0);
    stop = widget.timer?.stopTime ?? const TimeOfDay(hour: 17, minute: 0);
    _titleController.text = widget.timer?.title ?? "";
    _pinController.text = widget.timer?.espPin.toString() ?? "";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Schedule Motor",
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 20),

              // Title Input
              TextField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.white),
                decoration: _inputDecoration("Task Title (e.g. Irrigation)", Icons.label_outline),
              ),
              const SizedBox(height: 16),

              // Pin Input
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.white),
                decoration: _inputDecoration("ESP32 GPIO Pin Number", Icons.memory),
              ),
              const SizedBox(height: 24),

              // Time Selection Row
              Row(
                children: [
                  Expanded(child: _timePickerTile("Start Time", start, (t) => setState(() => start = t))),
                  const SizedBox(width: 12),
                  Expanded(child: _timePickerTile("Stop Time", stop, (t) => setState(() => stop = t))),
                ],
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: AppColors.gray500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        // 1. Validation: Ensure title and pin are valid
                        if (_titleController.text.isEmpty || _pinController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter Task Title and GPIO Pin")),
                          );
                          return;
                        }

                        // 2. Logic: Ensure Stop time is after Start time
                        final double startDouble = start.hour + start.minute / 60.0;
                        final double stopDouble = stop.hour + stop.minute / 60.0;

                        if (stopDouble <= startDouble) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Stop time must be after Start time")),
                          );
                          return;
                        }

                        // 3. Create the Object
                        final newTimer = TimerDevice(
                          id: widget.timer?.id ?? DateTime.now().toIso8601String(),
                          title: _titleController.text.trim(),
                          startTime: start,
                          stopTime: stop,
                          espPin: int.tryParse(_pinController.text) ?? 22, // Default GPIO
                          isEnabled: true,
                          day: widget.selectedDays.isNotEmpty ? widget.selectedDays.first : 1, // fallback to day 1
                        );


                        ref.read(automationViewModelProvider.notifier).addTimer(newTimer);




                        Navigator.pop(context);
                      },


                      child: const Text("SAVE SCHEDULE", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
      filled: true,
      fillColor: AppColors.black.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none
      ),
    );
  }

  Widget _timePickerTile(String label, TimeOfDay time, Function(TimeOfDay) onPick) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primary,
                  onPrimary: AppColors.black,
                  surface: AppColors.surfaceDark,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppColors.gray600, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
                time.format(context),
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ],
        ),
      ),
    );
  }
}