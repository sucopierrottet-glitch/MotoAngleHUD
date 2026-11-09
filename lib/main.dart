import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/welcome_landing_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  runApp(const MotoAngleHudApp());
}

/// Primary application widget for MotoAngleHUD Pro (SimpleAppsPG),
/// initialized with Obsidian Dark theme and reactive trilingual localization.
class MotoAngleHudApp extends StatelessWidget {
  const MotoAngleHudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StorageService.instance,
      builder: (context, _) {
        final localeCode = StorageService.instance.localeCode;
        return MaterialApp(
          title: 'MotoAngleHUD Pro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: Locale(localeCode),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es'),
            Locale('en'),
            Locale('pt'),
          ],
          home: const WelcomeLandingScreen(),
        );
      },
    );
  }
}
