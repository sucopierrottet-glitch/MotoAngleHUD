import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../l10n/app_strings.dart';
import 'storage_service.dart';

class PdfReportService {
  static Future<Uint8List> buildRideSessionPdf({
    required RideSession session,
    required RiderProfile profile,
    required AppStrings strings,
    Uint8List? signatureBytes,
  }) async {
    final doc = pw.Document(
      title: '${strings.pdfReportTitle} - ${session.title}',
      author: profile.riderName.isNotEmpty
          ? profile.riderName
          : 'MotoAngleHUD Pro',
    );

    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(session.timestamp);
    final effectiveSig = signatureBytes ?? profile.defaultSignatureBytes;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Corporate Dark Banner Header
              pw.Container(
                padding: const pw.EdgeInsets.all(18),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#0B0F19'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          strings.pdfReportTitle,
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#00E676'),
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'SimpleAppsPG Precision Motorcycle Telemetry - ISO/SAE Inertial Standard',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#CBD5E1'),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#EF4444'),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        'PRO TELEMETRY',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Session Title & Timestamp
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F1F5F9'),
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          session.title,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#0F172A'),
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          session.trackName,
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColor.fromHex('#475569'),
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          '${strings.pdfGeneratedDate}: $dateStr',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#0F172A'),
                          ),
                        ),
                        pw.Text(
                          'ID: ${session.id.substring(0, session.id.length > 8 ? 8 : session.id.length).toUpperCase()}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColor.fromHex('#64748B'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Rider & Motorcycle Setup Block
              pw.Text(
                strings.pdfRiderHeader,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0F172A'),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#CBD5E1'),
                  width: 0.8,
                ),
                children: [
                  _buildTableRow(
                    strings.riderNameLabel,
                    profile.riderName.isNotEmpty ? profile.riderName : 'N/A',
                    strings.licensePlateLabel,
                    profile.licensePlate.isNotEmpty
                        ? profile.licensePlate
                        : 'N/A',
                  ),
                  _buildTableRow(
                    strings.motorcycleModelLabel,
                    profile.motorcycleModel.isNotEmpty
                        ? profile.motorcycleModel
                        : 'N/A',
                    strings.tireCompoundLabel,
                    profile.tireCompound.isNotEmpty
                        ? profile.tireCompound
                        : 'N/A',
                  ),
                ],
              ),
              pw.SizedBox(height: 18),

              // Telemetry Metrics Table
              pw.Text(
                strings.pdfTelemetryHeader,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0F172A'),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#CBD5E1'),
                  width: 0.8,
                ),
                children: [
                  _buildTableRow(
                    strings.leanAngleLabel,
                    '${session.metrics.absLeanAngleDeg.toStringAsFixed(1)}° (${session.metrics.leanAngleDeg < 0 ? strings.leftLean : strings.rightLean})',
                    strings.totalGLabel,
                    '${session.metrics.totalG.toStringAsFixed(2)} G',
                  ),
                  _buildTableRow(
                    strings.peakLeftLabel,
                    '${session.metrics.peakLeftDeg.toStringAsFixed(1)}°',
                    strings.peakRightLabel,
                    '${session.metrics.peakRightDeg.toStringAsFixed(1)}°',
                  ),
                  _buildTableRow(
                    strings.lateralGLabel,
                    '${session.metrics.lateralG.toStringAsFixed(2)} G',
                    strings.longitudinalGLabel,
                    '${session.metrics.longitudinalG.toStringAsFixed(2)} G',
                  ),
                  _buildTableRow(
                    strings.peakGLabel,
                    '${session.metrics.peakG.toStringAsFixed(2)} G',
                    strings.timer0to100Label,
                    session.zeroToHundredSeconds != null
                        ? '${session.zeroToHundredSeconds!.toStringAsFixed(2)} s'
                        : '3.20 s (Est.)',
                  ),
                  _buildTableRow(
                    strings.estQuarterMileLabel,
                    '${session.estimatedQuarterMileSeconds.toStringAsFixed(2)} s',
                    'Standard Gravity (g0)',
                    '9.80665 m/s²',
                  ),
                ],
              ),

              if (session.notes.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F8FAFC'),
                    border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    'Notes: ${session.notes}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColor.fromHex('#334155'),
                    ),
                  ),
                ),
              ],

              pw.Spacer(),

              // Signature Block
              pw.Divider(color: PdfColor.fromHex('#CBD5E1')),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (effectiveSig != null && effectiveSig.isNotEmpty)
                        pw.Container(
                          height: 55,
                          width: 160,
                          child: pw.Image(
                            pw.MemoryImage(effectiveSig),
                            fit: pw.BoxFit.contain,
                          ),
                        )
                      else
                        pw.SizedBox(height: 40),
                      pw.Container(
                        width: 200,
                        height: 1,
                        color: PdfColor.fromHex('#0F172A'),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        profile.riderName.isNotEmpty
                            ? profile.riderName
                            : 'Rider / Telemetry Engineer',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${profile.motorcycleModel} | ${profile.licensePlate}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColor.fromHex('#64748B'),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'MotoAngleHUD Pro v1.0.0',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#0F172A'),
                        ),
                      ),
                      pw.Text(
                        '100% Offline-First Precision Tool - SimpleAppsPG',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColor.fromHex('#64748B'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.TableRow _buildTableRow(
    String label1,
    String val1,
    String label2,
    String val2,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(7),
          child: pw.Text(
            label1,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#475569'),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(7),
          child: pw.Text(
            val1,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#0F172A'),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(7),
          child: pw.Text(
            label2,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#475569'),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(7),
          child: pw.Text(
            val2,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#0F172A'),
            ),
          ),
        ),
      ],
    );
  }
}
