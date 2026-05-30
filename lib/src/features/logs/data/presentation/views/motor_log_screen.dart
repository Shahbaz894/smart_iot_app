import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/motor/data/models/motor_log_response.dart";


import "../providers/motor_log_providers.dart";
import "../state/motor_log_state.dart";

class MotorLogScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const MotorLogScreen({
    super.key,
    required this.deviceId,
  });

  @override
  ConsumerState<MotorLogScreen> createState() => _MotorLogScreenState();
}

class _MotorLogScreenState extends ConsumerState<MotorLogScreen> {
  String selectedFilter = "all";

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(motorLogViewModelProvider.notifier).loadLogs(widget.deviceId);
    });
  }

  List<MotorLogResponse> _filteredLogs(List<MotorLogResponse> logs) {
    if (selectedFilter == "all") return logs;

    return logs.where((log) {
      return (log.triggerType ?? "").toLowerCase() == selectedFilter;
    }).toList();
  }

  void _showSnack(
      String message,
      bool isError, {
        int seconds = 7,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: isError ? seconds : 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: isError ? Colors.redAccent : AppColors.green,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _deleteOne(MotorLogResponse log) async {
    final id = log.id;

    if (id == null || id.isEmpty) {
      _showSnack("Motor log ID missing", true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete log?"),
          content: const Text(
            "This will delete this motor log permanently.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(motorLogViewModelProvider.notifier).deleteLog(id);
  }

  Future<void> _clearAll() async {
    if (widget.deviceId.trim().isEmpty) {
      _showSnack("Device ID missing", true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clear all logs?"),
          content: const Text(
            "This will delete all motor logs for this device.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_sweep_rounded),
              label: const Text("Clear All"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(motorLogViewModelProvider.notifier).clearLogs(
      widget.deviceId,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MotorLogState>(
      motorLogViewModelProvider,
          (previous, next) {
        if (next.error != null && previous?.error != next.error) {
          _showSnack(next.error!, true, seconds: 10);
        }

        if (next.message != null && previous?.message != next.message) {
          _showSnack(next.message!, false);
        }
      },
    );

    final state = ref.watch(motorLogViewModelProvider);
    final logs = _filteredLogs(state.logs);

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 850;

    return Scaffold(
      backgroundColor: AppColors.darkBgSoft,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Motor Logs",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: state.isLoading
                ? null
                : () {
              ref
                  .read(motorLogViewModelProvider.notifier)
                  .loadLogs(widget.deviceId);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: "Clear all",
            onPressed: state.logs.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () {
            return ref
                .read(motorLogViewModelProvider.notifier)
                .loadLogs(widget.deviceId);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 18,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LogSummary(
                      total: state.logs.length,
                      manual: state.logs
                          .where(
                            (log) =>
                        (log.triggerType ?? "").toLowerCase() ==
                            "manual",
                      )
                          .length,
                      schedule: state.logs
                          .where(
                            (log) =>
                        (log.triggerType ?? "").toLowerCase() ==
                            "schedule",
                      )
                          .length,
                    ),
                    const SizedBox(height: 14),
                    _FilterBar(
                      selected: selectedFilter,
                      onChanged: (value) {
                        setState(() => selectedFilter = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    if (state.isLoading && logs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      )
                    else if (logs.isEmpty)
                      const _EmptyLogs()
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final twoColumns = constraints.maxWidth >= 760;

                          if (!twoColumns) {
                            return Column(
                              children: logs.map((log) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _MotorLogCard(
                                    log: log,
                                    onDelete: () => _deleteOne(log),
                                  ),
                                );
                              }).toList(),
                            );
                          }

                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: logs.map((log) {
                              return SizedBox(
                                width: (constraints.maxWidth - 14) / 2,
                                child: _MotorLogCard(
                                  log: log,
                                  onDelete: () => _deleteOne(log),
                                ),
                              );
                            }).toList(),
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

// class _LogSummary extends StatelessWidget {
//   final int total;
//   final int manual;
//   final int schedule;
//
//   const _LogSummary({
//     required this.total,
//     required this.manual,
//     required this.schedule,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth;
//
//         final crossAxisCount = width >= 720
//             ? 3
//             : width >= 460
//             ? 3
//             : 1;
//
//         final childAspectRatio = width >= 720
//             ? 2.25
//             : width >= 460
//             ? 1.55
//             : 3.4;
//
//         return GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: crossAxisCount,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//           childAspectRatio: childAspectRatio,
//           children: [
//             _SummaryTile(
//               title: "Total",
//               value: "$total",
//               icon: Icons.list_alt_rounded,
//             ),
//             _SummaryTile(
//               title: "Manual",
//               value: "$manual",
//               icon: Icons.touch_app_rounded,
//             ),
//             _SummaryTile(
//               title: "Schedule",
//               value: "$schedule",
//               icon: Icons.schedule_rounded,
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _SummaryTile extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//
//   const _SummaryTile({
//     required this.title,
//     required this.value,
//     required this.icon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: const BoxConstraints(minHeight: 82),
//       padding: const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 12,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.07)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 42,
//             width: 42,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(
//               icon,
//               color: AppColors.primary,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.58),
//                     fontWeight: FontWeight.w700,
//                     fontSize: 13,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     value,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
class _LogSummary extends StatelessWidget {
  final int total;
  final int manual;
  final int schedule;

  const _LogSummary({
    required this.total,
    required this.manual,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isVerySmall = screenWidth < 360;
    final isSmall = screenWidth < 420;

    final gap = isVerySmall ? 5.0 : isSmall ? 7.0 : 10.0;
    final height = isVerySmall ? 112.0 : isSmall ? 106.0 : 98.0;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _SummaryTile(
              title: "Total",
              value: "$total",
              icon: Icons.list_alt_rounded,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryTile(
              title: "Manual",
              value: "$manual",
              icon: Icons.touch_app_rounded,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryTile(
              title: "Schedule",
              value: "$schedule",
              icon: Icons.schedule_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isVerySmall = screenWidth < 360;
    final isSmall = screenWidth < 420;

    final padding = isVerySmall ? 7.0 : isSmall ? 9.0 : 12.0;
    final iconSize = isVerySmall ? 18.0 : isSmall ? 20.0 : 23.0;
    final titleSize = isVerySmall ? 9.5 : isSmall ? 10.5 : 12.0;
    final valueSize = isVerySmall ? 17.0 : isSmall ? 19.0 : 22.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: iconSize,
            ),
            SizedBox(height: isVerySmall ? 3 : 5),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.58),
                fontWeight: FontWeight.w700,
                fontSize: titleSize,
              ),
            ),
            SizedBox(height: isVerySmall ? 1 : 3),
            Text(
              value,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: valueSize,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterBar({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _LogChip(
            label: "All",
            value: "all",
            selected: selected,
            onChanged: onChanged,
          ),
          _LogChip(
            label: "Manual",
            value: "manual",
            selected: selected,
            onChanged: onChanged,
          ),
          _LogChip(
            label: "Schedule",
            value: "schedule",
            selected: selected,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _LogChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onChanged;

  const _LogChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = selected == value;

    return ChoiceChip(
      selected: active,
      label: Text(label),
      onSelected: (_) => onChanged(value),
    );
  }
}

class _MotorLogCard extends StatelessWidget {
  final MotorLogResponse log;
  final VoidCallback onDelete;

  const _MotorLogCard({
    required this.log,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final trigger = (log.triggerType ?? "manual").toLowerCase();
    final isSchedule = trigger == "schedule";
    final isRunning = log.endTime == null;

    final start = log.startTime;
    final end = log.endTime;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isRunning
                    ? AppColors.green.withOpacity(0.15)
                    : Colors.redAccent.withOpacity(0.15),
                child: Icon(
                  isRunning
                      ? Icons.power_settings_new_rounded
                      : Icons.power_off_rounded,
                  color: isRunning ? AppColors.green : Colors.redAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isRunning ? "Motor ON" : "Motor OFF",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: "Delete log",
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(
                text: isSchedule ? "SCHEDULE" : "MANUAL",
                color: isSchedule ? Colors.orange : AppColors.primary,
              ),
              _Tag(
                text: isRunning ? "RUNNING" : "STOPPED",
                color: isRunning ? AppColors.green : Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _LogInfo(
            label: "ON Date",
            value: _formatDate(start),
          ),
          _LogInfo(
            label: "ON Time",
            value: _formatTime(start),
          ),
          const Divider(color: Colors.white12),
          _LogInfo(
            label: "OFF Date",
            value: end == null ? "Running" : _formatDate(end),
          ),
          _LogInfo(
            label: "OFF Time",
            value: end == null ? "Running" : _formatTime(end),
          ),
          const Divider(color: Colors.white12),
          _LogInfo(
            label: "Run Duration",
            value: "${log.runHours.toStringAsFixed(2)} hr",
          ),
          _LogInfo(
            label: "Customer",
            value: log.customerName?.trim().isNotEmpty == true
                ? log.customerName!
                : "-",
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LogInfo extends StatelessWidget {
  final String label;
  final String value;

  const _LogInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.58),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLogs extends StatelessWidget {
  const _EmptyLogs();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.list_alt_rounded,
            color: AppColors.primary,
            size: 44,
          ),
          const SizedBox(height: 10),
          const Text(
            "No motor logs yet",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 6),
          Text(
            "Start and stop the motor to create logs.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.62),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return "-";
  return DateFormat("yyyy-MM-dd").format(value.toLocal());
}

String _formatTime(DateTime? value) {
  if (value == null) return "-";
  return DateFormat("hh:mm a").format(value.toLocal());
}