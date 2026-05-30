import "dart:io";
import "dart:typed_data";

import "package:intl/intl.dart";
import "package:path_provider/path_provider.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;
import "package:printing/printing.dart";
import "package:share_plus/share_plus.dart";

import "../models/khata_entry_model.dart";

class KhataPdfService {
  Future<void> previewEntryPdf(KhataEntryModel entry) async {
    await Printing.layoutPdf(
      onLayout: (_) => _buildEntryPdf(entry),
    );
  }

  Future<void> printEntryPdf(KhataEntryModel entry) async {
    await Printing.layoutPdf(
      onLayout: (_) => _buildEntryPdf(entry),
      name: _fileName(entry),
    );
  }

  Future<void> shareEntryPdf(KhataEntryModel entry) async {
    final file = await generateEntryPdf(entry);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Khata report for ${_safeText(entry.customerName, fallback: "Customer")}",
      subject: "Khata Report",
    );
  }

  Future<File> generateEntryPdf(KhataEntryModel entry) async {
    final bytes = await _buildEntryPdf(entry);
    final dir = await getTemporaryDirectory();

    final file = File("${dir.path}/${_fileName(entry)}");

    await file.writeAsBytes(bytes, flush: true);

    return file;
  }

  Future<Uint8List> _buildEntryPdf(KhataEntryModel entry) async {
    final pdf = pw.Document();
    final money = NumberFormat("#,##0.00");
    final generatedAt = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Text(
              "Page ${context.pageNumber} of ${context.pagesCount}",
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
          );
        },
        build: (context) {
          return [
            _header(entry),
            pw.SizedBox(height: 22),

            _sectionTitle("Customer Information"),
            pw.SizedBox(height: 8),
            _infoTable(
              rows: {
                "Customer Name": _safeText(entry.customerName),
                "Device ID": _safeText(entry.deviceId),
                "Motor Log ID": _safeText(entry.motorLogId),
                "Date": _safeText(entry.date),
              },
            ),

            pw.SizedBox(height: 20),

            _sectionTitle("Billing Details"),
            pw.SizedBox(height: 8),
            _infoTable(
              rows: {
                "Run Hours": entry.runHours.toStringAsFixed(2),
                "Price Per Hour": money.format(entry.pricePerHour),
                "Total Bill": money.format(entry.totalBill),
                "Cash Received": money.format(entry.cashReceived),
                "Remaining Balance": money.format(entry.remainingBalance),
                "Payment Status": entry.paymentStatus.toUpperCase(),
              },
            ),

            pw.SizedBox(height: 24),

            _summaryBox(entry, money),

            pw.SizedBox(height: 24),

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                "Generated on $generatedAt",
                style: const pw.TextStyle(
                  color: PdfColors.grey700,
                  fontSize: 10,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _header(KhataEntryModel entry) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey900,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "SMART WELL KHATA REPORT",
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                "Customer billing statement",
                style: const pw.TextStyle(
                  color: PdfColors.grey300,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(999),
            ),
            child: pw.Text(
              entry.paymentStatus.toUpperCase(),
              style: pw.TextStyle(
                color: _statusColor(entry.paymentStatus),
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blueGrey900,
      ),
    );
  }

  pw.Widget _infoTable({
    required Map<String, String> rows,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.25),
        1: pw.FlexColumnWidth(2),
      },
      children: rows.entries.map((entry) {
        return pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(9),
              color: PdfColors.grey100,
              child: pw.Text(
                entry.key,
                style: pw.TextStyle(
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(9),
              child: pw.Text(
                entry.value,
                style: const pw.TextStyle(
                  fontSize: 10.5,
                  color: PdfColors.grey900,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  pw.Widget _summaryBox(
      KhataEntryModel entry,
      NumberFormat money,
      ) {
    final isPaid = entry.remainingBalance <= 0;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: isPaid ? PdfColors.green50 : PdfColors.red50,
        border: pw.Border.all(
          color: isPaid ? PdfColors.green300 : PdfColors.red300,
        ),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                isPaid ? "Balance Cleared" : "Remaining Balance",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: isPaid ? PdfColors.green800 : PdfColors.red800,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                isPaid
                    ? "Customer has no pending balance."
                    : "Customer still has unpaid amount.",
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Text(
            money.format(entry.remainingBalance),
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: isPaid ? PdfColors.green800 : PdfColors.red800,
            ),
          ),
        ],
      ),
    );
  }

  PdfColor _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "paid":
        return PdfColors.green700;
      case "partial":
        return PdfColors.orange700;
      default:
        return PdfColors.red700;
    }
  }

  String _safeText(
      String? value, {
        String fallback = "-",
      }) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return fallback;
    }

    return text;
  }

  String _fileName(KhataEntryModel entry) {
    final customer = _safeText(
      entry.customerName,
      fallback: "customer",
    ).replaceAll(RegExp(r"[^a-zA-Z0-9]+"), "_");

    final date = DateFormat("yyyyMMdd_HHmmss").format(DateTime.now());

    return "khata_${customer}_$date.pdf";
  }
}