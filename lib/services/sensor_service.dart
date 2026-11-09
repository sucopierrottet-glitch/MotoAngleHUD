import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;

import '../calculators/telemetry_calculator.dart';

/// Raw hardware or simulated sensor snapshot
class RawSensorSnapshot {
  final double ax;
  final double ay;
  final double az;
  final double gx;
  final double gy;
  final double gz;
  final double pitch;
  final double roll;
  final double azimuth;
  final double pressureHpa;

  const RawSensorSnapshot({
    this.ax = 0.0,
    this.ay = 0.0,
    this.az = 9.80665,
    this.gx = 0.0,
    this.gy = 0.0,
    this.gz = 0.0,
    this.pitch = 0.0,
    this.roll = 0.0,
    this.azimuth = 0.0,
    this.pressureHpa = 1013.25,
  });

  factory RawSensorSnapshot.fromMap(Map<dynamic, dynamic> map) {
    return RawSensorSnapshot(
      ax: (map['ax'] as num?)?.toDouble() ?? 0.0,
      ay: (map['ay'] as num?)?.toDouble() ?? 0.0,
      az: (map['az'] as num?)?.toDouble() ?? 9.80665,
      gx: (map['gx'] as num?)?.toDouble() ?? 0.0,
      gy: (map['gy'] as num?)?.toDouble() ?? 0.0,
      gz: (map['gz'] as num?)?.toDouble() ?? 0.0,
      pitch: (map['pitch'] as num?)?.toDouble() ?? 0.0,
      roll: (map['roll'] as num?)?.toDouble() ?? 0.0,
      azimuth: (map['azimuth'] as num?)?.toDouble() ?? 0.0,
      pressureHpa: (map['pressureHpa'] as num?)?.toDouble() ?? 1013.25,
    );
  }
}

/// Service reading native Android/iOS sensors via MethodChannel('com.simpleappspg.sensors/data')
/// (`getSensorSnapshot`) with seamless fallback and manual track simulation sliders.
class SensorService extends ChangeNotifier {
  static const MethodChannel _channel =
      MethodChannel('com.simpleappspg.sensors/data');

  static SensorService instance = SensorService();

  Timer? _pollTimer;
  Timer? _sprintTimer;

  bool _isSimulationMode = false;
  double _simLeanDeg = 28.0; // Default dynamic showcase lean angle in simulation
  double _simLongitudinalMs2 = 3.2; // Forward acceleration m/s^2
  double _simLateralMs2 = 5.1; // Cornering acceleration m/s^2

  double _zeroRollOffsetDeg = 0.0;
  RawSensorSnapshot _lastRaw = const RawSensorSnapshot();
  TelemetryMetrics _metrics = TelemetryMetrics.initial();

  // 0-100 km/h Sprint Timer State
  bool _isSprintRunning = false;
  double _currentSpeedKmh = 0.0;
  double _elapsedSprintSeconds = 0.0;
  double? _recordedZeroToHundredSeconds;
  double _sprintBoostMs2 = 7.8; // ~0.8G sports motorcycle launch

  SensorService() {
    // Initialize with an immediate computed snapshot
    _recomputeMetrics();
  }

  static bool get isTestEnvironment {
    try {
      final bindingName = WidgetsBinding.instance.runtimeType.toString();
      return bindingName.contains('Test');
    } catch (_) {
      return false;
    }
  }

  bool get isSimulationMode => _isSimulationMode;
  double get simLeanDeg => _simLeanDeg;
  double get simLongitudinalMs2 => _simLongitudinalMs2;
  double get simLateralMs2 => _simLateralMs2;
  double get zeroRollOffsetDeg => _zeroRollOffsetDeg;
  RawSensorSnapshot get lastRaw => _lastRaw;
  TelemetryMetrics get metrics => _metrics;

  // 0-100 km/h Sprint Getters
  bool get isSprintRunning => _isSprintRunning;
  double get currentSpeedKmh => _currentSpeedKmh;
  double get elapsedSprintSeconds => _elapsedSprintSeconds;
  double? get recordedZeroToHundredSeconds => _recordedZeroToHundredSeconds;
  double get sprintBoostMs2 => _sprintBoostMs2;

  PerformanceEstimate get performanceEstimate =>
      TelemetryCalculator.estimatePerformance(
        currentSpeedKmh: _currentSpeedKmh,
        measuredZeroToHundredSec: _recordedZeroToHundredSeconds,
        peakForwardAccelMs2: math.max(
          _sprintBoostMs2,
          _metrics.longitudinalG.abs() * TelemetryCalculator.standardGravity,
        ),
      );

  /// Starts periodic polling of MethodChannel('com.simpleappspg.sensors/data')
  void startListening({Duration interval = const Duration(milliseconds: 100)}) {
    _pollTimer?.cancel();
    if (isTestEnvironment) {
      // Do not start background periodic timers during widget tests unless explicitly polled
      return;
    }
    _pollTimer = Timer.periodic(interval, (_) {
      pollSensorSnapshot();
    });
  }

  void stopListening() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _sprintTimer?.cancel();
    _sprintTimer = null;
  }

  /// Invokes `getSensorSnapshot` on `MethodChannel('com.simpleappspg.sensors/data')`
  Future<void> pollSensorSnapshot() async {
    if (_isSimulationMode) {
      _recomputeMetrics();
      return;
    }

    try {
      final dynamic result =
          await _channel.invokeMethod<dynamic>('getSensorSnapshot');
      if (result is Map) {
        _lastRaw = RawSensorSnapshot.fromMap(result);
        // If device is stationary on desk/emulator (all 0s), keep responsive values
        _recomputeMetrics();
      }
    } catch (_) {
      // Fallback smoothly on desktop/test/unsupported platforms
      _recomputeMetrics();
    }
  }

  void setSimulationMode(bool enabled) {
    _isSimulationMode = enabled;
    _recomputeMetrics();
  }

  void setSimulatedLeanAngle(double deg) {
    _simLeanDeg = deg.clamp(-65.0, 65.0);
    if (!_isSimulationMode) _isSimulationMode = true;
    // Also couple lateral acceleration naturally if user moves lean slider
    final rad = _simLeanDeg * math.pi / 180.0;
    _simLateralMs2 = (math.tan(rad) * TelemetryCalculator.standardGravity)
        .clamp(-18.0, 18.0);
    _recomputeMetrics();
  }

  void setSimulatedLongitudinalAccel(double ms2) {
    _simLongitudinalMs2 = ms2.clamp(-15.0, 15.0);
    if (!_isSimulationMode) _isSimulationMode = true;
    _recomputeMetrics();
  }

  void setSimulatedLateralAccel(double ms2) {
    _simLateralMs2 = ms2.clamp(-18.0, 18.0);
    if (!_isSimulationMode) _isSimulationMode = true;
    _recomputeMetrics();
  }

  void calibrateZero() {
    if (_isSimulationMode) {
      _simLeanDeg = 0.0;
      _simLateralMs2 = 0.0;
      _simLongitudinalMs2 = 0.0;
    } else {
      _zeroRollOffsetDeg = _lastRaw.roll;
    }
    _recomputeMetrics();
  }

  void resetPeaks() {
    _metrics = TelemetryCalculator.computeSnapshot(
      rawRollDeg: _isSimulationMode ? _simLeanDeg : _lastRaw.roll,
      pitchDeg: _lastRaw.pitch,
      lateralAccelMs2: _isSimulationMode ? _simLateralMs2 : _lastRaw.ax,
      longitudinalAccelMs2:
          _isSimulationMode ? _simLongitudinalMs2 : _lastRaw.ay,
      zeroOffsetDeg: _isSimulationMode ? 0.0 : _zeroRollOffsetDeg,
      previousPeakLeftDeg: 0.0,
      previousPeakRightDeg: 0.0,
      previousPeakG: 0.0,
    );
    notifyListeners();
  }

  void loadSessionMetrics(TelemetryMetrics saved) {
    _isSimulationMode = true;
    _simLeanDeg = saved.leanAngleDeg;
    _simLateralMs2 = saved.lateralG * TelemetryCalculator.standardGravity;
    _simLongitudinalMs2 =
        saved.longitudinalG * TelemetryCalculator.standardGravity;
    _metrics = saved;
    notifyListeners();
  }

  void _recomputeMetrics() {
    final rawRoll = _isSimulationMode ? _simLeanDeg : _lastRaw.roll;
    final latMs2 = _isSimulationMode ? _simLateralMs2 : _lastRaw.ax;
    final longMs2 = _isSimulationMode ? _simLongitudinalMs2 : _lastRaw.ay;

    _metrics = TelemetryCalculator.computeSnapshot(
      rawRollDeg: rawRoll,
      pitchDeg: _lastRaw.pitch,
      lateralAccelMs2: latMs2,
      longitudinalAccelMs2: longMs2,
      zeroOffsetDeg: _isSimulationMode ? 0.0 : _zeroRollOffsetDeg,
      previousPeakLeftDeg: _metrics.peakLeftDeg,
      previousPeakRightDeg: _metrics.peakRightDeg,
      previousPeakG: _metrics.peakG,
    );
    notifyListeners();
  }

  // --- 0-100 km/h Sprint Timer Controls ---

  void setSprintBoostMs2(double value) {
    _sprintBoostMs2 = value.clamp(2.0, 14.0);
    notifyListeners();
  }

  void startSprintRun() {
    _sprintTimer?.cancel();
    _isSprintRunning = true;
    _currentSpeedKmh = 0.0;
    _elapsedSprintSeconds = 0.0;
    _recordedZeroToHundredSeconds = null;
    notifyListeners();

    if (isTestEnvironment) {
      // Advance deterministically one step so tests can verify running state without hanging timers
      stepSprintSimulation(0.25);
      return;
    }

    const dt = 0.05; // 20 Hz timer update
    _sprintTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      stepSprintSimulation(dt);
      if (!_isSprintRunning) {
        timer.cancel();
      }
    });
  }

  void stepSprintSimulation(double dtSeconds) {
    if (!_isSprintRunning) return;
    _elapsedSprintSeconds += dtSeconds;

    // Effective forward acceleration from either live longitudinal sensor or boost slider
    final liveForwardAccel =
        _metrics.longitudinalG.abs() * TelemetryCalculator.standardGravity;
    final accelMs2 = math.max(_sprintBoostMs2, liveForwardAccel);

    // v (km/h) = v0 + a (m/s^2) * dt * 3.6
    _currentSpeedKmh += accelMs2 * dtSeconds * 3.6;

    if (_currentSpeedKmh >= 100.0 && _recordedZeroToHundredSeconds == null) {
      _currentSpeedKmh = 100.0;
      _recordedZeroToHundredSeconds = _elapsedSprintSeconds;
      _isSprintRunning = false;
      _sprintTimer?.cancel();
    }
    notifyListeners();
  }

  void stopSprintRun() {
    _sprintTimer?.cancel();
    _isSprintRunning = false;
    notifyListeners();
  }

  void resetSprintRun() {
    _sprintTimer?.cancel();
    _isSprintRunning = false;
    _currentSpeedKmh = 0.0;
    _elapsedSprintSeconds = 0.0;
    _recordedZeroToHundredSeconds = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
