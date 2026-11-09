import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../calculators/telemetry_calculator.dart';
import '../services/sensor_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/telemetry_painters.dart';

class CockpitScreen extends StatefulWidget {
  final VoidCallback? onOpenSessionsTab;

  const CockpitScreen({super.key, this.onOpenSessionsTab});

  @override
  State<CockpitScreen> createState() => _CockpitScreenState();
}

class _CockpitScreenState extends State<CockpitScreen> {
  final SensorService _sensor = SensorService.instance;
  final StorageService _storage = StorageService.instance;

  String _tr(String es, String en, String pt) {
    final lang = _storage.localeCode;
    if (lang.startsWith('en')) return en;
    if (lang.startsWith('pt')) return pt;
    return es;
  }

  @override
  void initState() {
    super.initState();
    _sensor.startListening();
  }

  Future<void> _saveCurrentSession() async {
    final titleCtrl = TextEditingController(
      text: _tr(
        'Tanda TrackDay #${DateTime.now().minute}',
        'TrackDay Session #${DateTime.now().minute}',
        'Sessão de Pista #${DateTime.now().minute}',
      ),
    );
    final trackCtrl = TextEditingController(
      text: _tr('Circuito GP / Curvas', 'GP Circuit / Twisties', 'Autódromo GP'),
    );
    final notesCtrl = TextEditingController(
      text: _tr(
        'Asfalto seco, telemetría registrada en vivo.',
        'Dry tarmac, live recorded telemetry.',
        'Asfalto seco, telemetria gravada ao vivo.',
      ),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final s = _storage.strings;
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          title: Text(
            s.saveRideSessionBtn,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key('inputSessionTitle'),
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: _tr('Nombre de la Sesión', 'Session Title',
                        'Nome da Sessão'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: trackCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: _tr('Circuito / Ruta', 'Circuit / Route',
                        'Autódromo / Rota'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: _tr('Notas Técnicas', 'Technical Notes',
                        'Notas Técnicas'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              key: const Key('btnConfirmSaveSession'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                s.save,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final perf = _sensor.performanceEstimate;
      final session = RideSession(
        id: const Uuid().v4(),
        title: titleCtrl.text.trim().isEmpty
            ? 'Track Session'
            : titleCtrl.text.trim(),
        trackName: trackCtrl.text.trim(),
        notes: notesCtrl.text.trim(),
        timestamp: DateTime.now(),
        metrics: _sensor.metrics,
        zeroToHundredSeconds: perf.zeroToHundredSeconds,
        estimatedQuarterMileSeconds: perf.estimatedQuarterMileSeconds,
      );
      await _storage.saveSession(session);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              'Sesión guardada en historial de telemetría',
              'Session saved to telemetry history',
              'Sessão salva no histórico de telemetria',
            ),
          ),
          backgroundColor: AppColors.neonGreen,
        ),
      );
      widget.onOpenSessionsTab?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_sensor, _storage]),
      builder: (context, _) {
        final s = _storage.strings;
        final m = _sensor.metrics;
        final zoneColor = AppColors.getLeanZoneColor(m.absLeanAngleDeg);

        String dirLabel = s.uprightStatus;
        if (m.direction == LeanDirection.left) dirLabel = s.leftLean;
        if (m.direction == LeanDirection.right) dirLabel = s.rightLean;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(
                  Icons.sports_motorsports_rounded,
                  color: AppColors.racingRed,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.cockpitTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                key: const Key('btnResetPeaks'),
                onPressed: _sensor.resetPeaks,
                icon: const Icon(
                  Icons.restart_alt_rounded,
                  size: 18,
                  color: AppColors.cautionAmber,
                ),
                label: Text(
                  s.resetPeaks,
                  style: const TextStyle(
                    color: AppColors.cautionAmber,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Primary Lean Angle Gauge Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: zoneColor.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPeakPill(
                            s.peakLeftLabel,
                            '${m.peakLeftDeg.toStringAsFixed(1)}°',
                            AppColors.racingRed,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: zoneColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: zoneColor),
                            ),
                            child: Text(
                              dirLabel,
                              style: TextStyle(
                                color: zoneColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          _buildPeakPill(
                            s.peakRightLabel,
                            '${m.peakRightDeg.toStringAsFixed(1)}°',
                            AppColors.neonGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 205,
                        width: double.infinity,
                        child: CustomPaint(
                          key: const Key('leanAngleGaugePaint'),
                          painter: LeanAngleGaugePainter(
                            leanAngleDeg: m.leanAngleDeg,
                            peakLeftDeg: m.peakLeftDeg,
                            peakRightDeg: m.peakRightDeg,
                          ),
                        ),
                      ),
                      Text(
                        '${m.absLeanAngleDeg.toStringAsFixed(1)}°',
                        key: const Key('txtCurrentLeanAngle'),
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w900,
                          color: zoneColor,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.leanAngleLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            key: const Key('btnCalibrateZero'),
                            onPressed: () {
                              _sensor.calibrateZero();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(s.calibratedToast),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppColors.neonGreen,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.gps_fixed_rounded,
                              size: 16,
                              color: AppColors.neonGreen,
                            ),
                            label: Text(
                              s.calibrateZeroBtn,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. 2D G-Force Ball Bullseye & Vector Readouts
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.gForceBallTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neonGreen,
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 155,
                            height: 155,
                            child: CustomPaint(
                              key: const Key('gForceBullseyePaint'),
                              painter: GForceBullseyePainter(
                                lateralG: m.lateralG,
                                longitudinalG: m.longitudinalG,
                                peakG: m.peakG,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                _buildGMetricRow(
                                  s.totalGLabel,
                                  '${m.totalG.toStringAsFixed(2)} G',
                                  AppColors.neonGreen,
                                ),
                                const SizedBox(height: 8),
                                _buildGMetricRow(
                                  s.peakGLabel,
                                  '${m.peakG.toStringAsFixed(2)} G',
                                  AppColors.racingRed,
                                ),
                                const SizedBox(height: 8),
                                _buildGMetricRow(
                                  s.lateralGLabel,
                                  '${m.lateralG >= 0 ? '+' : ''}${m.lateralG.toStringAsFixed(2)} G',
                                  AppColors.textPrimary,
                                ),
                                const SizedBox(height: 8),
                                _buildGMetricRow(
                                  s.longitudinalGLabel,
                                  '${m.longitudinalG >= 0 ? '+' : ''}${m.longitudinalG.toStringAsFixed(2)} G',
                                  AppColors.electricCyan,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Manual Track Simulation Sliders Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              s.simulationSectionTitle,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cautionAmber,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          Switch(
                            key: const Key('switchSimulationMode'),
                            value: _sensor.isSimulationMode,
                            activeThumbColor: AppColors.neonGreen,
                            onChanged: _sensor.setSimulationMode,
                          ),
                        ],
                      ),
                      Text(
                        s.simulationModeSwitch,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Simulated Lean Angle Slider (-60° to +60°)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s.simLeanSliderLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_sensor.simLeanDeg.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neonGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        key: const Key('sliderSimLean'),
                        value: _sensor.simLeanDeg.clamp(-60.0, 60.0),
                        min: -60.0,
                        max: 60.0,
                        activeColor: AppColors.racingRed,
                        onChanged: _sensor.setSimulatedLeanAngle,
                      ),

                      // Simulated Longitudinal Accel / Braking Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s.simLongGSliderLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_sensor.simLongitudinalMs2.toStringAsFixed(1)} m/s²',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.electricCyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        key: const Key('sliderSimLongAccel'),
                        value: _sensor.simLongitudinalMs2.clamp(-14.0, 14.0),
                        min: -14.0,
                        max: 14.0,
                        activeColor: AppColors.electricCyan,
                        onChanged: _sensor.setSimulatedLongitudinalAccel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Save Session CTA
                ElevatedButton.icon(
                  key: const Key('btnSaveRideSession'),
                  onPressed: _saveCurrentSession,
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: Text(
                    s.saveRideSessionBtn,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.racingRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeakPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGMetricRow(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
