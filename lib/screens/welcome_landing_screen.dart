import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_navigation_screen.dart';

class WelcomeLandingScreen extends StatelessWidget {
  const WelcomeLandingScreen({super.key});

  void _enterApp(BuildContext context, {int initialIndex = 0}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeNavigationScreen(
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StorageService.instance,
      builder: (context, _) {
        final s = StorageService.instance.strings;

        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // App Icon Badge
                  Center(
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.racingRed.withValues(alpha: 0.35),
                            blurRadius: 32,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.surfaceCard,
                          child: const Icon(
                            Icons.sports_motorsports_rounded,
                            size: 58,
                            color: AppColors.neonGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title & Subtitle
                  Text(
                    s.appTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.appSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Camino 1 Paid App Pro Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.neonGreen.withValues(alpha: 0.45),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.neonGreen,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'PRO EDITION • 100% OFFLINE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neonGreen,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Primary Action: Enter App
                  ElevatedButton.icon(
                    key: const Key('btnWelcomeEnter'),
                    onPressed: () => _enterApp(context, initialIndex: 0),
                    icon: const Icon(
                      Icons.speed_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      s.enterApp,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.racingRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Secondary Action: Quick Windshield HUD Mode
                  OutlinedButton.icon(
                    key: const Key('btnWelcomeHudMode'),
                    onPressed: () => _enterApp(context, initialIndex: 1),
                    icon: const Icon(
                      Icons.flip_rounded,
                      color: AppColors.neonGreen,
                    ),
                    label: Text(
                      s.startTrackSession,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.darkBorder),
                      backgroundColor: AppTheme.darkCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
