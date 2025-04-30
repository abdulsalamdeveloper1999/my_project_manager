
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';

import '../projects/data/models/project.dart';

class InvoiceService {
  // Generate an invoice for a project
  static Future<void> generateInvoice(Project project,
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      final pdf = pw.Document();

      // Filter time entries by date range if provided
      final filteredEntries = project.timeEntries.where((entry) {
        if (entry.endTime == null) return false;

        final entryDate = entry.startTime;
        if (startDate != null && entryDate.isBefore(startDate)) return false;
        if (endDate != null && entryDate.isAfter(endDate)) return false;

        return true;
      }).toList();

      if (filteredEntries.isEmpty) {
        throw Exception(
            'No completed time entries found in the selected date range');
      }

      // Calculate invoice details
      double totalHours = 0;
      for (final entry in filteredEntries) {
        if (entry.endTime != null) {
          final duration = entry.endTime!.difference(entry.startTime);
          totalHours += duration.inMinutes / 60;
        }
      }

      final totalAmount = totalHours * project.hourlyRate;
      final dateRange = startDate != null && endDate != null
          ? '${_formatDate(startDate)} to ${_formatDate(endDate)}'
          : 'All Sessions';

      // Generate invoice number
      final invoiceNumber =
          'INV-${project.id.substring(0, 6)}-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}';

      // Generate invoice PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              _buildInvoiceHeader(project, invoiceNumber, dateRange),
              pw.SizedBox(height: 20),
              _buildInvoiceDetails(project, filteredEntries),
              pw.SizedBox(height: 20),
              _buildInvoiceSummary(totalHours, project.hourlyRate, totalAmount),
            ];
          },
        ),
      );

      // Save the PDF
      final bytes = await pdf.save();

      // Save to file
      final fileName =
          'invoice_${project.clientName.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Use FileSaver for web and desktop platforms
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );

      debugPrint('✅ Invoice generated and saved successfully: $fileName');
    } catch (e) {
      debugPrint('❌ Error generating invoice: $e');
      rethrow;
    }
  }

  // Generate a session report for a project
  static Future<void> generateSessionReport(Project project) async {
    try {
      final pdf = pw.Document();

      // Sort entries by date (newest first)
      final sortedEntries = List.from(project.timeEntries)
        ..sort((a, b) => b.startTime.compareTo(a.startTime));

      if (sortedEntries.isEmpty) {
        throw Exception('No time entries found for this project');
      }

      // Generate report PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              _buildReportHeader(project),
              pw.SizedBox(height: 20),
              _buildSessionsTable(project, sortedEntries as List<TimeEntry>),
              pw.SizedBox(height: 20),
              _buildReportSummary(project),
            ];
          },
        ),
      );

      // Save the PDF
      final bytes = await pdf.save();

      // Save to file
      final fileName =
          'sessions_${project.clientName.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Use FileSaver for web and desktop platforms
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );

      debugPrint(
          '✅ Session report generated and saved successfully: $fileName');
    } catch (e) {
      debugPrint('❌ Error generating session report: $e');
      rethrow;
    }
  }

  // Helper methods for PDF generation

  static pw.Widget _buildInvoiceHeader(
      Project project, String invoiceNumber, String dateRange) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('INVOICE',
                    style: pw.TextStyle(
                        fontSize: 28, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Invoice #: $invoiceNumber'),
                pw.Text('Date: ${_formatDate(DateTime.now())}'),
                pw.Text('Period: $dateRange'),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue100,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Text(
                'Time Tracker',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bill To:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(project.clientName, style: pw.TextStyle(fontSize: 16)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Payment Terms:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Due on Receipt'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceDetails(
      Project project, List<TimeEntry> entries) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        // Table header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Description', isHeader: true),
            _buildTableCell('Hours',
                isHeader: true, alignment: pw.Alignment.centerRight),
            _buildTableCell('Rate',
                isHeader: true, alignment: pw.Alignment.centerRight),
            _buildTableCell('Amount',
                isHeader: true, alignment: pw.Alignment.centerRight),
          ],
        ),
        // Table rows for each entry
        ...entries.map((entry) {
          final duration = entry.endTime!.difference(entry.startTime);
          final hours = duration.inMinutes / 60;
          final amount = hours * project.hourlyRate;

          return pw.TableRow(
            children: [
              _buildTableCell(_formatDate(entry.startTime)),
              _buildTableCell(entry.description ?? 'Time tracking session'),
              _buildTableCell(hours.toStringAsFixed(2),
                  alignment: pw.Alignment.centerRight),
              _buildTableCell('\$${project.hourlyRate.toStringAsFixed(2)}',
                  alignment: pw.Alignment.centerRight),
              _buildTableCell('\$${amount.toStringAsFixed(2)}',
                  alignment: pw.Alignment.centerRight),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildInvoiceSummary(
      double totalHours, double hourlyRate, double totalAmount) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(
                width: 200,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Text('Total Hours:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                width: 100,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(totalHours.toStringAsFixed(2)),
              ),
            ],
          ),
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(
                width: 200,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Text('Hourly Rate:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                width: 100,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                alignment: pw.Alignment.centerRight,
                child: pw.Text('\$${hourlyRate.toStringAsFixed(2)}'),
              ),
            ],
          ),
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(
                width: 200,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  border: pw.Border.all(color: PdfColors.blue300),
                ),
                child: pw.Text('TOTAL DUE:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900)),
              ),
              pw.Container(
                width: 100,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue300),
                ),
                alignment: pw.Alignment.centerRight,
                child: pw.Text('\$${totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReportHeader(Project project) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('SESSION REPORT',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Project: ${project.clientName}',
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text('Generated: ${_formatDate(DateTime.now())}'),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue100,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Text(
                'Time Tracker',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildSessionsTable(
      Project project, List<TimeEntry> entries) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        // Table header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Date & Time', isHeader: true),
            _buildTableCell('Start Time', isHeader: true),
            _buildTableCell('End Time', isHeader: true),
            _buildTableCell('Duration',
                isHeader: true, alignment: pw.Alignment.centerRight),
            _buildTableCell('Description', isHeader: true),
          ],
        ),
        // Table rows for each entry
        ...entries.map((entry) {
          final isComplete = entry.endTime != null;
          final duration = isComplete
              ? entry.endTime!.difference(entry.startTime)
              : const Duration();
          final hours = duration.inMinutes / 60;

          return pw.TableRow(
            children: [
              _buildTableCell(_formatDate(entry.startTime)),
              _buildTableCell(_formatTime(entry.startTime)),
              _buildTableCell(
                  isComplete ? _formatTime(entry.endTime!) : 'In Progress'),
              _buildTableCell(
                isComplete ? _formatDuration(duration) : 'N/A',
                alignment: pw.Alignment.centerRight,
              ),
              _buildTableCell(entry.description ?? ''),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildReportSummary(Project project) {
    // Calculate total hours and earnings
    double totalHours = 0;
    int completedSessions = 0;

    for (final entry in project.timeEntries) {
      if (entry.endTime != null) {
        final duration = entry.endTime!.difference(entry.startTime);
        totalHours += duration.inMinutes / 60;
        completedSessions++;
      }
    }

    final totalEarnings = totalHours * project.hourlyRate;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Summary',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Sessions:'),
              pw.Text(project.timeEntries.length.toString()),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Completed Sessions:'),
              pw.Text(completedSessions.toString()),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Hours:'),
              pw.Text(totalHours.toStringAsFixed(2)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Hourly Rate:'),
              pw.Text('\$${project.hourlyRate.toStringAsFixed(2)}'),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Divider(),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Earnings:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('\$${totalEarnings.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for formatting

  static pw.Widget _buildTableCell(String text,
      {bool isHeader = false,
      pw.Alignment alignment = pw.Alignment.centerLeft}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: alignment,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  static String _formatDate(DateTime dateTime) {
    return DateFormat('MM/dd/yyyy').format(dateTime);
  }

  static String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }
}
