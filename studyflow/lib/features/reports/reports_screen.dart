import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_code/l10n/app_localizations.dart';
import '../../data/local/hive_storage.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Future<Uint8List> _generatePdf(PdfPageFormat format, AppLocalizations l10n) async {
    final pdf = pw.Document();
    final tasks = HiveStorage.getTasks();
    final sessions = HiveStorage.getSessions();
    
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalStudyTime = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final totalHours = (totalStudyTime / 60).toStringAsFixed(1);

    // Standard PDF page generation for supported languages (EN, ES, PT)

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(l10n.pdfTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text(l10n.pdfGeneratedOn(DateFormat('MMMM d, yyyy', l10n.localeName).format(DateTime.now()))),
              pw.SizedBox(height: 40),
              
              pw.Text(l10n.pdfSummary, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(l10n.pdfTotalTasks, '${tasks.length}'),
                  _buildStatItem(l10n.pdfCompleted, '$completedTasks'),
                  _buildStatItem(l10n.pdfPending, '${tasks.length - completedTasks}'),
                  _buildStatItem(l10n.pdfStudyHours, '$totalHours h'),
                ],
              ),
              pw.SizedBox(height: 40),
              
              pw.Text(l10n.pdfRecentSessions, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>[l10n.pdfColDate, l10n.pdfColDuration, l10n.pdfColTask],
                  ...sessions.take(10).map((session) => [
                    DateFormat('MMM d, h:mm a', l10n.localeName).format(session.completedDate),
                    session.durationMinutes.toString(),
                    session.taskId ?? l10n.pdfFocusSession,
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
      ],
    );
  }

  void _exportPdf(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final pdfData = await _generatePdf(PdfPageFormat.a4, l10n);
      if (!context.mounted) return;
      
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/study_report.pdf');
      await file.writeAsBytes(pdfData);
      
      await Share.shareXFiles([XFile(file.path)], text: l10n.pdfTitle);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reportError(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              l10n.reportGenerate,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                l10n.reportDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _exportPdf(context),
              icon: const Icon(Icons.download),
              label: Text(l10n.reportExportPdf),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () async {
                final pdfData = await _generatePdf(PdfPageFormat.a4, l10n);
                await Printing.layoutPdf(
                  onLayout: (PdfPageFormat format) async => pdfData,
                );
              },
              icon: const Icon(Icons.print),
              label: Text(l10n.reportPrint),
            ),
          ],
        ),
      ),
    );
  }
}
