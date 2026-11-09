import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../services/pdf_report_service.dart';
import '../services/sensor_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/signature_dialog.dart';

class SavedSessionsScreen extends StatefulWidget {
  final VoidCallback? onBackToCockpit;

  const SavedSessionsScreen({super.key, this.onBackToCockpit});

  @override
  State<SavedSessionsScreen> createState() => _SavedSessionsScreenState();
}

class _SavedSessionsScreenState extends State<SavedSessionsScreen> {
  final StorageService _storage = StorageService.instance;
  List<RideSession> _sessions = [];
  bool _isLoading = true;

  String _tr(String es, String en, String pt) {
    final lang = _storage.localeCode;
    if (lang.startsWith('en')) return en;
    if (lang.startsWith('pt')) return pt;
    return es;
  }

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _storage.addListener(_loadSessions);
  }

  @override
  void dispose() {
    _storage.removeListener(_loadSessions);
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final list = await _storage.getSavedSessions();
    if (!mounted) return;
    setState(() {
      _sessions = list;
      _isLoading = false;
    });
  }

  Future<void> _exportSessionPdf(RideSession session) async {
    var profile = await _storage.getProfile();
    if (!mounted) return;

    // Prompt signature dialog if no default signature or allow signing
    final sigResult = await SignatureDialog.show(
      context,
      riderName: profile.riderName,
      motorcycleModel: profile.motorcycleModel,
      licensePlate: profile.licensePlate,
    );

    if (sigResult != null) {
      profile = profile.copyWith(
        riderName: sigResult.riderName,
        motorcycleModel: sigResult.motorcycleModel,
        licensePlate: sigResult.licensePlate,
        defaultSignatureBase64: base64Encode(sigResult.signatureBytes),
      );
      await _storage.saveProfile(profile);
    }

    if (!mounted) return;
    final pdfBytes = await PdfReportService.buildRideSessionPdf(
      session: session,
      profile: profile,
      strings: _storage.strings,
      signatureBytes: sigResult?.signatureBytes ?? profile.defaultSignatureBytes,
    );

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            title: Text(session.title),
          ),
          body: PdfPreview(
            build: (_) async => pdfBytes,
            canChangeOrientation: false,
            canChangePageFormat: false,
            pdfFileName: 'MotoAngleHUD_${session.id.substring(0, 6)}.pdf',
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSession(RideSession session) async {
    await _storage.deleteSession(session.id);
    await _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _storage,
      builder: (context, _) {
        final s = _storage.strings;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            title: Text(s.savedSessionsTitle),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.racingRed),
                )
              : _sessions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.sports_score_rounded,
                              size: 64,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              s.noSessionsTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              s.noSessionsDesc,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _sessions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _sessions[index];
                        final dateStr = DateFormat('dd/MM/yyyy HH:mm')
                            .format(item.timestamp);
                        final zoneColor = AppColors.getLeanZoneColor(
                          item.metrics.absLeanAngleDeg,
                        );

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.trackName} • $dateStr',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.racingRed,
                                    ),
                                    onPressed: () => _deleteSession(item),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildMiniStat(
                                    s.leanAngleLabel,
                                    '${item.metrics.absLeanAngleDeg.toStringAsFixed(1)}°',
                                    zoneColor,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildMiniStat(
                                    '${s.peakLeftLabel}/${s.peakRightLabel}',
                                    '${item.metrics.peakLeftDeg.toStringAsFixed(0)}° / ${item.metrics.peakRightDeg.toStringAsFixed(0)}°',
                                    AppColors.neonGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildMiniStat(
                                    s.peakGLabel,
                                    '${item.metrics.peakG.toStringAsFixed(2)} G',
                                    AppColors.electricCyan,
                                  ),
                                ],
                              ),
                              if (item.notes.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  item.notes,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        SensorService.instance
                                            .loadSessionMetrics(item.metrics);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              _tr(
                                                'Sesión cargada en el Cockpit',
                                                'Session loaded into Cockpit',
                                                'Sessão carregada no Cockpit',
                                              ),
                                            ),
                                            backgroundColor:
                                                AppColors.neonGreen,
                                          ),
                                        );
                                        widget.onBackToCockpit?.call();
                                      },
                                      icon: const Icon(
                                        Icons.speed_rounded,
                                        size: 16,
                                        color: AppColors.neonGreen,
                                      ),
                                      label: Text(
                                        s.loadSessionBtn,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      key: Key('btnExportPdf_$index'),
                                      onPressed: () => _exportSessionPdf(item),
                                      icon: const Icon(
                                        Icons.picture_as_pdf_rounded,
                                        size: 16,
                                      ),
                                      label: Text(
                                        s.exportPdfBtn,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.racingRed,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
