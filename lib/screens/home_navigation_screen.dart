import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'cockpit_screen.dart';
import 'hud_mirror_screen.dart';
import 'saved_sessions_screen.dart';
import 'settings_screen.dart';

class HomeNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const HomeNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StorageService.instance,
      builder: (context, _) {
        final s = StorageService.instance.strings;

        final screens = [
          CockpitScreen(
            onOpenSessionsTab: () => setState(() => _currentIndex = 2),
          ),
          const HudMirrorScreen(),
          SavedSessionsScreen(
            onBackToCockpit: () => setState(() => _currentIndex = 0),
          ),
          const SettingsScreen(),
        ];

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (_currentIndex != 0) {
              setState(() => _currentIndex = 0);
              return;
            }
            SystemNavigator.pop();
          },
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: AppTheme.darkSurface,
                border: Border(
                  top: BorderSide(color: AppTheme.darkBorder, width: 1),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 62,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.speed_outlined,
                        activeIcon: Icons.speed_rounded,
                        label: s.tabCockpit,
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.flip_outlined,
                        activeIcon: Icons.flip_rounded,
                        label: s.tabHudMirror,
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.folder_special_outlined,
                        activeIcon: Icons.folder_special_rounded,
                        label: s.tabSavedSessions,
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.tune_rounded,
                        activeIcon: Icons.tune_rounded,
                        label: s.tabSettings,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        key: Key('navTab_$index'),
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.neonGreen : AppTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color:
                    isSelected ? AppColors.neonGreen : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
