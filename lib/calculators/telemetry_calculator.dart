import 'dart:math' as math;

/// Direction of motorcycle lean angle
enum LeanDirection { left, right, upright }

/// Immutable snapshot of motorcycle telemetry calculations
class TelemetryMetrics {
  /// Signed lean angle in degrees (-65° Left to +65° Right)
  final double leanAngleDeg;

  /// Absolute lean angle in degrees (0° to 65°)
  final double absLeanAngleDeg;

  /// Direction of lean (left, right, or upright within +/- 1.0°)
  final LeanDirection direction;

  /// Peak left lean angle recorded during session (0° to 65°)
  final double peakLeftDeg;

  /// Peak right lean angle recorded during session (0° to 65°)
  final double peakRightDeg;

  /// Lateral G-force (cornering: negative = left, positive = right)
  final double lateralG;

  /// Longitudinal G-force (positive = acceleration, negative = braking)
  final double longitudinalG;

  /// Combined 2D G-force vector magnitude: sqrt(latG^2 + longG^2)
  final double totalG;

  /// Peak total G-force recorded during session
  final double peakG;

  /// Pitch angle in degrees
  final double pitchDeg;

  const TelemetryMetrics({
    required this.leanAngleDeg,
    required this.absLeanAngleDeg,
    required this.direction,
    required this.peakLeftDeg,
    required this.peakRightDeg,
    required this.lateralG,
    required this.longitudinalG,
    required this.totalG,
    required this.peakG,
    this.pitchDeg = 0.0,
  });

  factory TelemetryMetrics.initial() => const TelemetryMetrics(
        leanAngleDeg: 0.0,
        absLeanAngleDeg: 0.0,
        direction: LeanDirection.upright,
        peakLeftDeg: 0.0,
        peakRightDeg: 0.0,
        lateralG: 0.0,
        longitudinalG: 0.0,
        totalG: 0.0,
        peakG: 0.0,
        pitchDeg: 0.0,
      );

  Map<String, dynamic> toJson() => {
        'leanAngleDeg': leanAngleDeg,
        'absLeanAngleDeg': absLeanAngleDeg,
        'direction': direction.name,
        'peakLeftDeg': peakLeftDeg,
        'peakRightDeg': peakRightDeg,
        'lateralG': lateralG,
        'longitudinalG': longitudinalG,
        'totalG': totalG,
        'peakG': peakG,
        'pitchDeg': pitchDeg,
      };

  factory TelemetryMetrics.fromJson(Map<String, dynamic> json) {
    final dirName = json['direction'] as String? ?? 'upright';
    final dir = LeanDirection.values.firstWhere(
      (d) => d.name == dirName,
      orElse: () => LeanDirection.upright,
    );
    return TelemetryMetrics(
      leanAngleDeg: (json['leanAngleDeg'] as num?)?.toDouble() ?? 0.0,
      absLeanAngleDeg: (json['absLeanAngleDeg'] as num?)?.toDouble() ?? 0.0,
      direction: dir,
      peakLeftDeg: (json['peakLeftDeg'] as num?)?.toDouble() ?? 0.0,
      peakRightDeg: (json['peakRightDeg'] as num?)?.toDouble() ?? 0.0,
      lateralG: (json['lateralG'] as num?)?.toDouble() ?? 0.0,
      longitudinalG: (json['longitudinalG'] as num?)?.toDouble() ?? 0.0,
      totalG: (json['totalG'] as num?)?.toDouble() ?? 0.0,
      peakG: (json['peakG'] as num?)?.toDouble() ?? 0.0,
      pitchDeg: (json['pitchDeg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Performance & 0-100 km/h sprint estimator result
class PerformanceEstimate {
  final double currentSpeedKmh;
  final double? zeroToHundredSeconds;
  final double estimatedQuarterMileSeconds;
  final double estimatedQuarterMileTrapKmh;
  final double estimatedPowerToWeightHpPerKg;
  final double peakAccelerationG;

  const PerformanceEstimate({
    required this.currentSpeedKmh,
    this.zeroToHundredSeconds,
    required this.estimatedQuarterMileSeconds,
    required this.estimatedQuarterMileTrapKmh,
    required this.estimatedPowerToWeightHpPerKg,
    required this.peakAccelerationG,
  });
}

/// Precision calculator for Motorcycle Lean Angle, G-Force ($g = a/9.80665$),
/// and 0-100 km/h performance metrics.
class TelemetryCalculator {
  static const double standardGravity = 9.80665;
  static const double maxLeanAngleClamp = 65.0;

  /// Converts linear acceleration ($m/s^2$) to G-Force ($g = a / 9.80665$).
  static double accelerationToG(double metersPerSecondSquared) {
    if (metersPerSecondSquared.isNaN || metersPerSecondSquared.isInfinite) {
      return 0.0;
    }
    return metersPerSecondSquared / standardGravity;
  }

  /// Calculates motorcycle lean angle in degrees from raw roll and calibration offset.
  /// Negative values indicate Left lean; positive values indicate Right lean.
  static double calculateLeanAngle({
    required double rawRollDeg,
    double zeroOffsetDeg = 0.0,
  }) {
    if (rawRollDeg.isNaN || rawRollDeg.isInfinite) return 0.0;
    final adjusted = rawRollDeg - zeroOffsetDeg;
    return adjusted.clamp(-maxLeanAngleClamp, maxLeanAngleClamp);
  }

  /// Determines lean direction with a 1.0° upright deadband.
  static LeanDirection resolveDirection(double leanAngleDeg) {
    if (leanAngleDeg < -1.0) return LeanDirection.left;
    if (leanAngleDeg > 1.0) return LeanDirection.right;
    return LeanDirection.upright;
  }

  /// Computes full telemetry metrics including Peak Hold for Left/Right lean and G-Force.
  static TelemetryMetrics computeSnapshot({
    required double rawRollDeg,
    required double pitchDeg,
    required double lateralAccelMs2,
    required double longitudinalAccelMs2,
    double zeroOffsetDeg = 0.0,
    double previousPeakLeftDeg = 0.0,
    double previousPeakRightDeg = 0.0,
    double previousPeakG = 0.0,
  }) {
    final lean = calculateLeanAngle(
      rawRollDeg: rawRollDeg,
      zeroOffsetDeg: zeroOffsetDeg,
    );
    final absLean = lean.abs();
    final dir = resolveDirection(lean);

    double peakLeft = previousPeakLeftDeg;
    double peakRight = previousPeakRightDeg;
    if (lean < 0 && absLean > peakLeft) {
      peakLeft = absLean;
    } else if (lean > 0 && absLean > peakRight) {
      peakRight = absLean;
    }

    final latG = accelerationToG(lateralAccelMs2).clamp(-3.0, 3.0);
    final longG = accelerationToG(longitudinalAccelMs2).clamp(-3.0, 3.0);
    final totG = math.sqrt(latG * latG + longG * longG);
    final peakG = totG > previousPeakG ? totG : previousPeakG;

    return TelemetryMetrics(
      leanAngleDeg: lean,
      absLeanAngleDeg: absLean,
      direction: dir,
      peakLeftDeg: peakLeft,
      peakRightDeg: peakRight,
      lateralG: latG,
      longitudinalG: longG,
      totalG: totG,
      peakG: peakG,
      pitchDeg: pitchDeg.isNaN ? 0.0 : pitchDeg.clamp(-60.0, 60.0),
    );
  }

  /// Theoretical steady-state lean angle from lateral acceleration: $\theta = \arctan(g_{lat})$
  static double theoreticalLeanFromLateralG(double lateralG) {
    if (lateralG.isNaN || lateralG.isInfinite) return 0.0;
    final rad = math.atan(lateralG.abs());
    return (rad * 180.0 / math.pi).clamp(0.0, maxLeanAngleClamp);
  }

  /// Estimates 0-100 km/h sprint time, 1/4 mile ET, and power-to-weight index
  /// from average forward acceleration ($m/s^2$) or measured 0-100 time.
  static PerformanceEstimate estimatePerformance({
    required double currentSpeedKmh,
    double? measuredZeroToHundredSec,
    required double peakForwardAccelMs2,
  }) {
    final effectiveAccel = peakForwardAccelMs2.clamp(1.0, 14.5);
    final peakG = accelerationToG(effectiveAccel);

    // 100 km/h = 27.7778 m/s
    final estimated0to100 = measuredZeroToHundredSec ??
        (27.7778 / (effectiveAccel * 0.82)).clamp(2.2, 25.0);

    // Empirical quarter-mile (402.336 m) estimator for motorcycles based on 0-100 km/h time
    final estQuarterMileSec = (estimated0to100 * 1.65 + 4.85).clamp(8.5, 22.0);
    final estTrapSpeedKmh = (295.0 - estimated0to100 * 14.5).clamp(110.0, 290.0);

    // Approximate HP/kg ratio from peak forward G
    final hpPerKg = (peakG * 0.68).clamp(0.08, 1.25);

    return PerformanceEstimate(
      currentSpeedKmh: currentSpeedKmh.clamp(0.0, 350.0),
      zeroToHundredSeconds: measuredZeroToHundredSec ?? estimated0to100,
      estimatedQuarterMileSeconds: estQuarterMileSec,
      estimatedQuarterMileTrapKmh: estTrapSpeedKmh,
      estimatedPowerToWeightHpPerKg: hpPerKg,
      peakAccelerationG: peakG,
    );
  }
}
