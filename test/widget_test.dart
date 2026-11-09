import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:motoanglehud/calculators/telemetry_calculator.dart';
import 'package:motoanglehud/l10n/app_strings.dart';
import 'package:motoanglehud/main.dart';
import 'package:motoanglehud/services/pdf_report_service.dart';
import 'package:motoanglehud/services/sensor_service.dart';
import 'package:motoanglehud/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.instance = StorageService();
    await StorageService.instance.init();
    SensorService.instance = SensorService();
  });

  group('TelemetryCalculator Unit Tests', () {
    test('Converts acceleration to G-force using g = a / 9.80665', () {
      expect(
        TelemetryCalculator.accelerationToG(9.80665),
        closeTo(1.0, 1e-5),
      );
      expect(
        TelemetryCalculator.accelerationToG(-4.903325),
        closeTo(-0.5, 1e-5),
      );
    });

    test('Computes lean angle, direction, and peak hold left/right', () {
      final snap1 = TelemetryCalculator.computeSnapshot(
        rawRollDeg: -42.5,
        pitchDeg: -2.0,
        lateralAccelMs2: -8.5,
        longitudinalAccelMs2: 4.9,
      );
      expect(snap1.leanAngleDeg, closeTo(-42.5, 1e-4));
      expect(snap1.absLeanAngleDeg, closeTo(42.5, 1e-4));
      expect(snap1.direction, LeanDirection.left);
      expect(snap1.peakLeftDeg, closeTo(42.5, 1e-4));
      expect(snap1.peakRightDeg, 0.0);

      final snap2 = TelemetryCalculator.computeSnapshot(
        rawRollDeg: 51.0,
        pitchDeg: 1.0,
        lateralAccelMs2: 9.80665,
        longitudinalAccelMs2: 0.0,
        previousPeakLeftDeg: snap1.peakLeftDeg,
        previousPeakRightDeg: snap1.peakRightDeg,
        previousPeakG: snap1.peakG,
      );
      expect(snap2.direction, LeanDirection.right);
      expect(snap2.peakLeftDeg, closeTo(42.5, 1e-4));
      expect(snap2.peakRightDeg, closeTo(51.0, 1e-4));
      expect(snap2.lateralG, closeTo(1.0, 1e-4));
    });

    test('Estimates 0-100 km/h sprint and quarter mile performance', () {
      final est = TelemetryCalculator.estimatePerformance(
        currentSpeedKmh: 85.0,
        measuredZeroToHundredSec: 3.10,
        peakForwardAccelMs2: 9.80665,
      );
      expect(est.currentSpeedKmh, 85.0);
      expect(est.zeroToHundredSeconds, 3.10);
      expect(est.peakAccelerationG, closeTo(1.0, 1e-4));
      expect(est.estimatedQuarterMileSeconds, greaterThan(9.0));
    });
  });

  group('PDF Report Generation & Localization Tests', () {
    test('Generates valid PDF bytes for a saved ride session', () async {
      final sessions = await StorageService.instance.getSavedSessions();
      expect(sessions, isNotEmpty);
      final profile = await StorageService.instance.getProfile();

      final bytes = await PdfReportService.buildRideSessionPdf(
        session: sessions.first,
        profile: profile,
        strings: AppStrings.es,
      );
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });
  });

  group('MotoAngleHUD Widget & Navigation Tests', () {
    testWidgets('WelcomeLandingScreen enters HomeNavigationScreen and switches 4 tabs + ES/EN/PT', (WidgetTester tester) async {
      await tester.pumpWidget(const MotoAngleHudApp());
      await tester.pumpAndSettle();

      // Verify WelcomeLandingScreen and Key('btnWelcomeEnter')
      final enterBtn = find.byKey(const Key('btnWelcomeEnter'));
      expect(enterBtn, findsOneWidget);
      expect(find.text('MOTOANGLE HUD'), findsOneWidget);

      await tester.tap(enterBtn);
      await tester.pumpAndSettle();

      // Tab 0: Cockpit Screen with Lean Angle Gauge & 2D G-Force Ball
      expect(find.byKey(const Key('leanAngleGaugePaint')), findsOneWidget);
      expect(find.byKey(const Key('gForceBullseyePaint')), findsOneWidget);

      // Adjust simulation slider
      SensorService.instance.setSimulatedLeanAngle(-45.0);
      await tester.pump();
      expect(find.text('45.0°'), findsWidgets);

      // Tab 1: Windshield Mirror HUD Mode & 0-100 Timer
      await tester.tap(find.byKey(const Key('navTab_1')));
      await tester.pumpAndSettle();

      final mirrorSwitch = find.byKey(const Key('switchWindshieldMirror'));
      expect(mirrorSwitch, findsOneWidget);
      await tester.tap(mirrorSwitch);
      await tester.pumpAndSettle();

      // Verify Transform.scale is present
      expect(find.byKey(const Key('hudMirrorTransform')), findsOneWidget);

      // Tab 2: Saved Ride Sessions
      await tester.tap(find.byKey(const Key('navTab_2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('btnExportPdf_0')), findsOneWidget);

      // Tab 3: Settings & 1-tap ES/EN/PT switcher
      await tester.tap(find.byKey(const Key('navTab_3')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('langOption_en')));
      await tester.pumpAndSettle();
      expect(StorageService.instance.localeCode, 'en');
      expect(find.text('Settings & Rider Profile'), findsOneWidget);

      await tester.tap(find.byKey(const Key('langOption_pt')));
      await tester.pumpAndSettle();
      expect(StorageService.instance.localeCode, 'pt');
      expect(find.text('Ajustes & Perfil do Piloto'), findsOneWidget);
    });
  });
}
