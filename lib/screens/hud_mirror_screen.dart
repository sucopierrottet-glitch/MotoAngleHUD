import 'package:flutter/material.dart';

import '../calculators/telemetry_calculator.dart';
import '../services/sensor_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/telemetry_painters.dart';

class HudMirrorScreen extends StatefulWidget {
  const HudMirrorScreen({super.key});

  @override
  State<HudMirrorScreen> createState() => _HudMirrorScreenState();
}

class _HudMirrorScreenState extends State<HudMirrorScreen> {
  final SensorService _sensor = SensorService.instance;
  final StorageService _storage = StorageService.instance;

  bool _isWindshieldMirror = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_sensor, _storage]),
      builder: (context, _) {
        final s = _storage.strings;
        final m = _sensor.metrics;
        final perf = _sensor.performanceEstimate;
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
                  Icons.flip_rounded,
                  color: AppColors.neonGreen,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.hudMirrorTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  const Text(
                    'HUD X:-1',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neonGreen,
                    ),
                  ),
                  Switch(
                    key: const Key('switchWindshieldMirror'),
                    value: _isWindshieldMirror,
                    activeThumbColor: AppColors.neonGreen,
                    onChanged: (v) => setState(() => _isWindshieldMirror = v),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Mirror Mode Toggle Banner
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isWindshieldMirror
                        ? AppColors.neonGreen.withValues(alpha: 0.14)
                        : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isWindshieldMirror
                          ? AppColors.neonGreen
                          : AppColors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isWindshieldMirror
                            ? Icons.flip_camera_android_rounded
                            : Icons.visibility_rounded,
                        color: _isWindshieldMirror
                            ? AppColors.neonGreen
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isWindshieldMirror
                              ? s.mirrorModeActiveHint
                              : s.mirrorModeNormalHint,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _isWindshieldMirror
                                ? AppColors.neonGreen
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Windshield HUD Reflection Projection Panel (Transform.scale scaleX: -1)
                Transform.scale(
                  key: const Key('hudMirrorTransform'),
                  scaleX: _isWindshieldMirror ? -1.0 : 1.0,
                  scaleY: 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF060911),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.neonGreen.withValues(alpha: 0.65),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonGreen.withValues(alpha: 0.12),
                          blurRadius: 24,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'L ${m.peakLeftDeg.toStringAsFixed(0)}°',
                              style: const TextStyle(
                                color: AppColors.racingRed,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              dirLabel,
                              style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                              ),
                            ),
                            Text(
                              'R ${m.peakRightDeg.toStringAsFixed(0)}°',
                              style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 155,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: LeanAngleGaugePainter(
                              leanAngleDeg: m.leanAngleDeg,
                              peakLeftDeg: m.peakLeftDeg,
                              peakRightDeg: m.peakRightDeg,
                              highContrastHud: true,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${m.absLeanAngleDeg.toStringAsFixed(0)}°',
                                  style: TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    color: zoneColor,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  s.leanAngleLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1.5,
                              height: 54,
                              color: AppColors.borderSubtle,
                            ),
                            Column(
                              children: [
                                Text(
                                  perf.currentSpeedKmh.toStringAsFixed(0),
                                  key: const Key('txtHudSpeedKmh'),
                                  style: const TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.neonGreen,
                                    height: 1.0,
                                  ),
                                ),
                                const Text(
                                  'KM/H',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1.5,
                              height: 54,
                              color: AppColors.borderSubtle,
                            ),
                            Column(
                              children: [
                                Text(
                                  m.totalG.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.electricCyan,
                                    height: 1.1,
                                  ),
                                ),
                                const Text(
                                  'G-FORCE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 3. 0-100 km/h Timer & Performance Estimator Card
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
                      Text(
                        s.timerSectionTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.racingRed,
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPerfBox(
                              s.timer0to100Label,
                              '${(perf.zeroToHundredSeconds ?? 3.20).toStringAsFixed(2)} s',
                              AppColors.neonGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildPerfBox(
                              s.estQuarterMileLabel,
                              '${perf.estimatedQuarterMileSeconds.toStringAsFixed(2)} s @ ${perf.estimatedQuarterMileTrapKmh.toStringAsFixed(0)} km/h',
                              AppColors.cautionAmber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPerfBox(
                              s.estPowerWeightLabel,
                              '${perf.estimatedPowerToWeightHpPerKg.toStringAsFixed(2)} HP/kg',
                              AppColors.electricCyan,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildPerfBox(
                              s.peakGLabel,
                              '${perf.peakAccelerationG.toStringAsFixed(2)} G',
                              AppColors.racingRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Launch Acceleration Boost Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s.simThrottleBoostLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_sensor.sprintBoostMs2.toStringAsFixed(1)} m/s²',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neonGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        key: const Key('sliderSprintBoost'),
                        value: _sensor.sprintBoostMs2.clamp(2.0, 14.0),
                        min: 2.0,
                        max: 14.0,
                        activeColor: AppColors.neonGreen,
                        onChanged: _sensor.setSprintBoostMs2,
                      ),
                      const SizedBox(height: 8),

                      // Start / Stop / Reset Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              key: const Key('btnStartSprintTimer'),
                              onPressed: _sensor.isSprintRunning
                                  ? _sensor.stopSprintRun
                                  : _sensor.startSprintRun,
                              icon: Icon(
                                _sensor.isSprintRunning
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              label: Text(
                                _sensor.isSprintRunning
                                    ? s.stopRunBtn
                                    : s.startRunBtn,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _sensor.isSprintRunning
                                    ? AppColors.racingRed
                                    : AppColors.neonGreen,
                                foregroundColor: _sensor.isSprintRunning
                                    ? Colors.white
                                    : Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              key: const Key('btnResetSprintTimer'),
                              onPressed: _sensor.resetSprintRun,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: Text(s.resetRunBtn),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerfBox(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: accent,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
