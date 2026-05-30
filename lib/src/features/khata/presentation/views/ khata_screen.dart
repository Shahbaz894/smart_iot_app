

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";

import "../../../../core/utils/app_theme_colours.dart";
import "../../data/models/khata_entry_model.dart";
import "../providers/ khata_providers.dart";
import "../state/khata_state.dart";

// TODO: update this import path according to your project structure.


import "../../data/models/khata_entry_model.dart";
import "../providers/ khata_providers.dart";
import "../state/khata_state.dart";

class KhataScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const KhataScreen({
    super.key,
    required this.deviceId,
  });

  @override
  ConsumerState<KhataScreen> createState() => _KhataScreenState();
}

class _KhataScreenState extends ConsumerState<KhataScreen> {
  final TextEditingController searchController = TextEditingController();

  String query = "";
  String selectedStatus = "all";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(khataViewModelProvider.notifier).loadEntries();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    return ref.read(khataViewModelProvider.notifier).loadEntries();
  }

  List<KhataEntryModel> _filteredEntries(List<KhataEntryModel> entries) {
    final search = query.trim().toLowerCase();

    var result = entries;

    if (selectedStatus != "all") {
      result = result.where((entry) {
        return entry.paymentStatus.toLowerCase() == selectedStatus;
      }).toList();
    }

    if (search.isEmpty) return result;

    return result.where((entry) {
      return entry.customerName.toLowerCase().contains(search) ||
          entry.deviceId.toLowerCase().contains(search) ||
          entry.paymentStatus.toLowerCase().contains(search) ||
          entry.date.toLowerCase().contains(search);
    }).toList();
  }

  void _showSnack(
      String message,
      bool isError, {
        int seconds = 8,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: isError ? seconds : 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
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

  Future<void> _showPriceSheet(KhataEntryModel entry) async {
    final priceController = TextEditingController(
      text: entry.pricePerHour > 0 ? entry.pricePerHour.toString() : "",
    );

    final cashController = TextEditingController(
      text: entry.cashReceived > 0 ? entry.cashReceived.toString() : "0",
    );

    final result = await showModalBottomSheet<_BillInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        return _KhataBottomSheet(
          bottom: bottom,
          title: "Calculate Bill",
          subtitle: "Run hours: ${entry.runHours.toStringAsFixed(2)}",
          children: [
            _SheetField(
              controller: priceController,
              label: "Price per hour",
              icon: Icons.price_change_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: cashController,
              label: "Cash received",
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _PrimarySheetButton(
              icon: Icons.calculate_rounded,
              label: "Calculate Bill",
              onPressed: () {
                final price = double.tryParse(priceController.text.trim()) ?? 0;
                final cash = double.tryParse(cashController.text.trim()) ?? 0;

                Navigator.pop(
                  context,
                  _BillInput(
                    pricePerHour: price,
                    cashReceived: cash,
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    priceController.dispose();
    cashController.dispose();

    if (result == null) return;

    await ref.read(khataViewModelProvider.notifier).updatePriceAndBill(
      entry: entry,
      pricePerHour: result.pricePerHour,
      cashReceived: result.cashReceived,
    );
  }

  Future<void> _showPaymentSheet(KhataEntryModel entry) async {
    final amountController = TextEditingController();

    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        return _KhataBottomSheet(
          bottom: bottom,
          title: "Add Payment",
          subtitle: entry.customerName,
          children: [
            _SheetField(
              controller: amountController,
              label: "Amount received",
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _PrimarySheetButton(
              icon: Icons.check_rounded,
              label: "Save Payment",
              color: AppColors.green,
              foregroundColor: AppColors.white,
              onPressed: () {
                final value = double.tryParse(amountController.text.trim()) ?? 0;
                Navigator.pop(context, value);
              },
            ),
          ],
        );
      },
    );

    amountController.dispose();

    if (amount == null) return;

    await ref.read(khataViewModelProvider.notifier).addPayment(
      entry: entry,
      amount: amount,
    );
  }

  Future<void> _showEditSheet(KhataEntryModel entry) async {
    final nameController = TextEditingController(text: entry.customerName);
    final hoursController = TextEditingController(
      text: entry.runHours.toStringAsFixed(2),
    );
    final priceController = TextEditingController(
      text: entry.pricePerHour.toString(),
    );
    final cashController = TextEditingController(
      text: entry.cashReceived.toString(),
    );

    final updated = await showModalBottomSheet<KhataEntryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        return _KhataBottomSheet(
          bottom: bottom,
          title: "Update Khata Entry",
          subtitle: "Edit customer, hours, rate, and received cash",
          children: [
            _SheetField(
              controller: nameController,
              label: "Customer name",
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: hoursController,
              label: "Run hours",
              icon: Icons.timer_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: priceController,
              label: "Price per hour",
              icon: Icons.price_change_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: cashController,
              label: "Cash received",
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _PrimarySheetButton(
              icon: Icons.save_rounded,
              label: "Update Entry",
              onPressed: () {
                final name = nameController.text.trim();
                final hours = double.tryParse(hoursController.text.trim()) ?? 0;
                final price = double.tryParse(priceController.text.trim()) ?? 0;
                final cash = double.tryParse(cashController.text.trim()) ?? 0;

                final totalBill = hours * price;
                final remaining = totalBill - cash;

                Navigator.pop(
                  context,
                  entry.copyWith(
                    customerName: name.isEmpty ? entry.customerName : name,
                    runHours: hours,
                    pricePerHour: price,
                    cashReceived: cash,
                    totalBill: totalBill,
                    remainingBalance: remaining <= 0 ? 0 : remaining,
                    paymentStatus: _paymentStatus(
                      cashReceived: cash,
                      totalBill: totalBill,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    nameController.dispose();
    hoursController.dispose();
    priceController.dispose();
    cashController.dispose();

    if (updated == null) return;

    await ref.read(khataViewModelProvider.notifier).updateEntry(updated);
  }

  Future<void> _confirmDelete(KhataEntryModel entry) async {
    final id = entry.id;

    if (id == null || id.isEmpty) {
      _showSnack("Khata entry ID missing", true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemeColors.card(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            "Delete Khata entry?",
            style: TextStyle(
              color: AppThemeColors.text(context),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            "This will permanently delete the entry for ${entry.customerName}.",
            style: TextStyle(
              color: AppThemeColors.subText(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: AppThemeColors.subText(context)),
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(khataViewModelProvider.notifier).deleteEntry(id);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<KhataState>(
      khataViewModelProvider,
          (previous, next) {
        if (next.error != null && previous?.error != next.error) {
          _showSnack(next.error!, true, seconds: 12);
        }

        if (next.message != null && previous?.message != next.message) {
          _showSnack(next.message!, false);
        }
      },
    );

    final state = ref.watch(khataViewModelProvider);

    final deviceEntries = state.entries;
    final entries = _filteredEntries(state.entries);

    final totalBill = entries.fold<double>(
      0,
          (sum, item) => sum + item.totalBill,
    );

    final totalReceived = entries.fold<double>(
      0,
          (sum, item) => sum + item.cashReceived,
    );

    final totalRemaining = entries.fold<double>(
      0,
          (sum, item) => sum + item.remainingBalance,
    );

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 850;

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppThemeColors.appBarText(context),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Khata",
              style: TextStyle(
                color: AppThemeColors.appBarText(context),
                fontWeight: FontWeight.w900,
                fontSize: 21,
              ),
            ),
            const SizedBox(height: 2),
            Center(
              child: Text(
                "Customer billing and balances",
                style: TextStyle(
                  color: AppThemeColors.subText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: state.isLoading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppThemeColors.surface(context),
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 18,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DeviceHeader(
                      deviceId: widget.deviceId,
                      count: deviceEntries.length,
                    ),
                    const SizedBox(height: 16),
                    _SummaryGrid(
                      totalBill: totalBill,
                      totalReceived: totalReceived,
                      totalRemaining: totalRemaining,
                      count: entries.length,
                    ),
                    const SizedBox(height: 16),
                    _SearchAndFilters(
                      searchController: searchController,
                      selectedStatus: selectedStatus,
                      onSearchChanged: (value) {
                        setState(() => query = value);
                      },
                      onStatusChanged: (value) {
                        setState(() => selectedStatus = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (state.isLoading && entries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(34),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (widget.deviceId.trim().isEmpty)
                      const _EmptyKhata(
                        title: "Device ID missing",
                        message: "Please select a device first.",
                      )
                    else if (deviceEntries.isEmpty)
                        _EmptyKhata(
                          title: "No Khata entries for this device",
                          message:
                          "Entries for ${widget.deviceId} will appear after motor runs are billed.",
                        )
                      else if (entries.isEmpty)
                          const _EmptyKhata(
                            title: "No matching entries",
                            message: "Try changing search text or payment filter.",
                          )
                        else
                          _KhataList(
                            entries: entries,
                            onSetPrice: _showPriceSheet,
                            onPayment: _showPaymentSheet,
                            onEdit: _showEditSheet,
                            onDelete: _confirmDelete,
                            onSharePdf: (entry) {
                              ref.read(khataPdfServiceProvider).shareEntryPdf(entry);
                            },
                            onPreviewPdf: (entry) {
                              ref
                                  .read(khataPdfServiceProvider)
                                  .previewEntryPdf(entry);
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

class _KhataList extends StatelessWidget {
  final List<KhataEntryModel> entries;
  final ValueChanged<KhataEntryModel> onSetPrice;
  final ValueChanged<KhataEntryModel> onPayment;
  final ValueChanged<KhataEntryModel> onEdit;
  final ValueChanged<KhataEntryModel> onDelete;
  final ValueChanged<KhataEntryModel> onSharePdf;
  final ValueChanged<KhataEntryModel> onPreviewPdf;

  const _KhataList({
    required this.entries,
    required this.onSetPrice,
    required this.onPayment,
    required this.onEdit,
    required this.onDelete,
    required this.onSharePdf,
    required this.onPreviewPdf,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 840;

        if (!twoColumns) {
          return Column(
            children: entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _KhataCard(
                  entry: entry,
                  onSetPrice: () => onSetPrice(entry),
                  onPayment: () => onPayment(entry),
                  onEdit: () => onEdit(entry),
                  onDelete: () => onDelete(entry),
                  onSharePdf: () => onSharePdf(entry),
                  onPreviewPdf: () => onPreviewPdf(entry),
                ),
              );
            }).toList(),
          );
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: entries.map((entry) {
            return SizedBox(
              width: (constraints.maxWidth - 16) / 2,
              child: _KhataCard(
                entry: entry,
                onSetPrice: () => onSetPrice(entry),
                onPayment: () => onPayment(entry),
                onEdit: () => onEdit(entry),
                onDelete: () => onDelete(entry),
                onSharePdf: () => onSharePdf(entry),
                onPreviewPdf: () => onPreviewPdf(entry),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _DeviceHeader extends StatelessWidget {
  final String deviceId;
  final int count;

  const _DeviceHeader({
    required this.deviceId,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.mintAccentDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Device Khata Ledger",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deviceId.isEmpty ? "No device selected" : deviceId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gray300,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.white.withOpacity(0.12),
              ),
            ),
            child: Text(
              "$count entries",
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStatus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;

  const _SearchAndFilters({
    required this.searchController,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppThemeColors.cardDecoration(context),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: TextStyle(
              color: AppThemeColors.text(context),
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: "Search customer, date, device, or status",
              hintStyle: TextStyle(color: AppThemeColors.subText(context)),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              filled: true,
              fillColor: AppThemeColors.input(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppThemeColors.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppThemeColors.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  label: "All",
                  value: "all",
                  selectedStatus: selectedStatus,
                  onChanged: onStatusChanged,
                ),
                _StatusChip(
                  label: "Unpaid",
                  value: "unpaid",
                  selectedStatus: selectedStatus,
                  onChanged: onStatusChanged,
                ),
                _StatusChip(
                  label: "Partial",
                  value: "partial",
                  selectedStatus: selectedStatus,
                  onChanged: onStatusChanged,
                ),
                _StatusChip(
                  label: "Paid",
                  value: "paid",
                  selectedStatus: selectedStatus,
                  onChanged: onStatusChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final String selectedStatus;
  final ValueChanged<String> onChanged;

  const _StatusChip({
    required this.label,
    required this.value,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedStatus == value;
    final selectedColor = _statusColor(value);

    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onChanged(value),
      selectedColor: selectedColor,
      backgroundColor: AppThemeColors.input(context),
      side: BorderSide(
        color: selected ? selectedColor : AppThemeColors.border(context),
      ),
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppThemeColors.text(context),
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final double totalBill;
  final double totalReceived;
  final double totalRemaining;
  final int count;

  const _SummaryGrid({
    required this.totalBill,
    required this.totalReceived,
    required this.totalRemaining,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 4 ? 1.72 : 1.38,
          children: [
            _SummaryCard(
              label: "Entries",
              value: "$count",
              icon: Icons.receipt_long_rounded,
              accent: AppColors.primary,
            ),
            _SummaryCard(
              label: "Total Bill",
              value: _money(totalBill),
              icon: Icons.account_balance_wallet_rounded,
              accent: AppColors.info,
            ),
            _SummaryCard(
              label: "Received",
              value: _money(totalReceived),
              icon: Icons.payments_rounded,
              accent: AppColors.success,
            ),
            _SummaryCard(
              label: "Remaining",
              value: _money(totalRemaining),
              icon: Icons.warning_amber_rounded,
              accent: totalRemaining > 0 ? AppColors.error : AppColors.success,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppThemeColors.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppThemeColors.subText(context),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                color: AppThemeColors.text(context),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KhataCard extends StatelessWidget {
  final KhataEntryModel entry;
  final VoidCallback onSetPrice;
  final VoidCallback onPayment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSharePdf;
  final VoidCallback onPreviewPdf;

  const _KhataCard({
    required this.entry,
    required this.onSetPrice,
    required this.onPayment,
    required this.onEdit,
    required this.onDelete,
    required this.onSharePdf,
    required this.onPreviewPdf,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(entry.paymentStatus);
    final canAddPayment = entry.totalBill > 0 && entry.remainingBalance > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppThemeColors.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.14),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.customerName.isEmpty ? "-" : entry.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeColors.text(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                color: AppThemeColors.card(context),
                iconColor: AppThemeColors.subText(context),
                onSelected: (value) {
                  if (value == "edit") onEdit();
                  if (value == "delete") onDelete();
                  if (value == "preview") onPreviewPdf();
                  if (value == "share") onSharePdf();
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: "edit",
                      child: Text(
                        "Update",
                        style: TextStyle(color: AppThemeColors.text(context)),
                      ),
                    ),
                    PopupMenuItem(
                      value: "preview",
                      child: Text(
                        "Preview PDF",
                        style: TextStyle(color: AppThemeColors.text(context)),
                      ),
                    ),
                    PopupMenuItem(
                      value: "share",
                      child: Text(
                        "Share PDF",
                        style: TextStyle(color: AppThemeColors.text(context)),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: "delete",
                      child: Text(
                        "Delete",
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusBadge(
                label: entry.paymentStatus.toUpperCase(),
                color: statusColor,
              ),
              _SoftBadge(
                icon: Icons.calendar_today_rounded,
                label: entry.date.isEmpty ? "-" : entry.date,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: "Device", value: entry.deviceId),
          _InfoRow(
            label: "Run Hours",
            value: entry.runHours.toStringAsFixed(2),
          ),
          _InfoRow(
            label: "Price Per Hour",
            value: _money(entry.pricePerHour),
          ),
          _InfoRow(
            label: "Total Bill",
            value: _money(entry.totalBill),
          ),
          _InfoRow(
            label: "Cash Received",
            value: _money(entry.cashReceived),
          ),
          _InfoRow(
            label: "Remaining",
            value: _money(entry.remainingBalance),
            strong: true,
            strongColor:
            entry.remainingBalance > 0 ? AppColors.error : AppColors.success,
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: entry.pricePerHour <= 0 ? "Set Rate" : "Rate",
                      icon: Icons.calculate_rounded,
                      color: AppColors.primary,
                      textColor: AppColors.black,
                      filled: true,
                      onTap: onSetPrice,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: "Add Payment",
                      icon: Icons.add_card_rounded,
                      color: AppColors.green,
                      textColor: AppColors.white,
                      filled: true,
                      onTap: canAddPayment ? onPayment : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: "Update",
                      icon: Icons.edit_rounded,
                      color: AppColors.primary,
                      textColor: AppColors.primary,
                      filled: false,
                      onTap: onEdit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: "Delete",
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.error,
                      textColor: AppColors.error,
                      filled: false,
                      onTap: onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SoftBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppThemeColors.input(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppThemeColors.subText(context)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: AppThemeColors.subText(context),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return SizedBox(
      height: 44,
      child: filled
          ? ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: FittedBox(child: Text(label)),
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? color : AppColors.disabledDark,
          foregroundColor: enabled ? textColor : AppColors.gray500,
          disabledBackgroundColor: AppColors.disabledDark,
          disabledForegroundColor: AppColors.gray500,
          elevation: enabled ? 4 : 0,
          shadowColor: color.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      )
          : OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: FittedBox(child: Text(label)),
        style: OutlinedButton.styleFrom(
          foregroundColor: enabled ? textColor : AppColors.gray500,
          side: BorderSide(
            color: enabled ? color.withOpacity(0.55) : AppColors.gray600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;
  final Color? strongColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.strongColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppThemeColors.subText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: strong
                    ? (strongColor ?? AppColors.primary)
                    : AppThemeColors.text(context),
                fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KhataBottomSheet extends StatelessWidget {
  final double bottom;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _KhataBottomSheet({
    required this.bottom,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(color: AppThemeColors.border(context)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppThemeColors.border(context),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppThemeColors.text(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppThemeColors.subText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: AppThemeColors.text(context),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppThemeColors.subText(context)),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppThemeColors.input(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppThemeColors.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppThemeColors.border(context)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _PrimarySheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? foregroundColor;

  const _PrimarySheetButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    final fg = foregroundColor ?? AppColors.black;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 4,
          shadowColor: bg.withOpacity(0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _EmptyKhata extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyKhata({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: AppThemeColors.cardDecoration(context),
      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeColors.text(context),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeColors.subText(context),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillInput {
  final double pricePerHour;
  final double cashReceived;

  const _BillInput({
    required this.pricePerHour,
    required this.cashReceived,
  });
}

Color _statusColor(String value) {
  switch (value.toLowerCase()) {
    case "paid":
      return AppColors.success;
    case "partial":
      return AppColors.warning;
    case "all":
      return AppColors.primary;
    default:
      return AppColors.error;
  }
}

String _paymentStatus({
  required double cashReceived,
  required double totalBill,
}) {
  if (totalBill <= 0) return "unpaid";
  if (cashReceived >= totalBill) return "paid";
  if (cashReceived > 0) return "partial";
  return "unpaid";
}

String _money(double value) {
  return value.toStringAsFixed(2);
}





