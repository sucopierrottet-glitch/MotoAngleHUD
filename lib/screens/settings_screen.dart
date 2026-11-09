import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/signature_dialog.dart';
import 'welcome_landing_screen.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService? storageService;

  const SettingsScreen({super.key, this.storageService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _riderController = TextEditingController();
  final _motoController = TextEditingController();
  final _plateController = TextEditingController();
  final _tireController = TextEditingController();
  final _clubController = TextEditingController();

  String? _defaultSignatureBase64;
  bool _isLoading = true;

  StorageService get _storage =>
      widget.storageService ?? StorageService.instance;

  String _tr(String es, String en, String pt) {
    final lang = _storage.localeCode;
    if (lang.startsWith('en')) return en;
    if (lang.startsWith('pt')) return pt;
    return es;
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _riderController.dispose();
    _motoController.dispose();
    _plateController.dispose();
    _tireController.dispose();
    _clubController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final profile = await _storage.getProfile();
    if (!mounted) return;
    setState(() {
      _riderController.text = profile.riderName;
      _motoController.text = profile.motorcycleModel;
      _plateController.text = profile.licensePlate;
      _tireController.text = profile.tireCompound;
      _clubController.text = profile.trackClub;
      _defaultSignatureBase64 = profile.defaultSignatureBase64;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final current = await _storage.getProfile();
    final updated = current.copyWith(
      riderName: _riderController.text.trim(),
      motorcycleModel: _motoController.text.trim(),
      licensePlate: _plateController.text.trim(),
      tireCompound: _tireController.text.trim(),
      trackClub: _clubController.text.trim(),
      defaultSignatureBase64: _defaultSignatureBase64,
      clearDefaultSignature: _defaultSignatureBase64 == null,
    );
    await _storage.saveProfile(updated);
    if (!mounted) return;
    final s = _storage.strings;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.settingsSavedSuccess),
        backgroundColor: AppColors.neonGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _captureDefaultSignature() async {
    final res = await SignatureDialog.show(
      context,
      riderName: _riderController.text.trim(),
      motorcycleModel: _motoController.text.trim(),
      licensePlate: _plateController.text.trim(),
    );
    if (res != null && mounted) {
      setState(() {
        _defaultSignatureBase64 = base64Encode(res.signatureBytes);
        if (_riderController.text.trim().isEmpty) {
          _riderController.text = res.riderName;
        }
        if (_motoController.text.trim().isEmpty) {
          _motoController.text = res.motorcycleModel;
        }
        if (_plateController.text.trim().isEmpty) {
          _plateController.text = res.licensePlate;
        }
      });
      await _saveSettings();
    }
  }

  Future<void> _shareApp() async {
    const playUrl =
        'https://play.google.com/store/apps/details?id=com.simpleappspg.motoanglehud';
    final msg = _tr(
      'Descubre MotoAngleHUD Pro — Inclinómetro, Fuerza G 2D y Telemetría HUD para motocicleta: $playUrl',
      'Check out MotoAngleHUD Pro — Motorcycle Lean Angle Gauge, 2D G-Force & Windshield HUD: $playUrl',
      'Conheça o MotoAngleHUD Pro — Inclinômetro, Força G 2D e Telemetria HUD para motocicleta: $playUrl',
    );
    await SharePlus.instance.share(ShareParams(text: msg));
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(
      'https://sucopierrottet-glitch.github.io/motoanglehud-privacy/',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _storage,
      builder: (context, _) {
        final s = _storage.strings;
        final currentLang = _storage.localeCode;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            title: Text(s.settingsTitle),
            actions: [
              IconButton(
                key: const Key('btnSaveSettingsAppBar'),
                icon: const Icon(
                  Icons.check_rounded,
                  color: AppColors.neonGreen,
                ),
                tooltip: s.save,
                onPressed: _saveSettings,
              ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.racingRed),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. 1-Tap Language Switcher (ES / EN / PT)
                      _buildSectionTitle(s.languageSelectorTitle),
                      const SizedBox(height: 10),
                      Material(
                        color: AppColors.surfaceCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            _buildLanguageOption(
                              code: 'es',
                              flag: '🇪🇸',
                              label: 'Español',
                              currentLang: currentLang,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.borderSubtle,
                            ),
                            _buildLanguageOption(
                              code: 'en',
                              flag: '🇺🇸',
                              label: 'English',
                              currentLang: currentLang,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.borderSubtle,
                            ),
                            _buildLanguageOption(
                              code: 'pt',
                              flag: '🇧🇷',
                              label: 'Português',
                              currentLang: currentLang,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. Camino 1 Paid App Banner (100% Pro Unlocked, No Paywall)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF059669),
                              Color(0xFF047857),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.proUnlockedTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.proUnlockedSubtitle,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Rider & Motorcycle Setup Fields
                      _buildSectionTitle(s.riderProfileHeader),
                      const SizedBox(height: 6),
                      Text(
                        s.riderProfileDesc,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('inputSettingsRiderName'),
                        controller: _riderController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: s.riderNameLabel,
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('inputSettingsMotoModel'),
                        controller: _motoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: s.motorcycleModelLabel,
                          prefixIcon: const Icon(
                            Icons.two_wheeler_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('inputSettingsPlate'),
                        controller: _plateController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: s.licensePlateLabel,
                          prefixIcon: const Icon(
                            Icons.tag_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('inputSettingsTire'),
                        controller: _tireController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: s.tireCompoundLabel,
                          prefixIcon: const Icon(
                            Icons.album_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('inputSettingsClub'),
                        controller: _clubController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: s.trackClubLabel,
                          prefixIcon: const Icon(
                            Icons.flag_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. Default Signature Setup
                      OutlinedButton.icon(
                        key: const Key('btnConfigureDefaultSignature'),
                        onPressed: _captureDefaultSignature,
                        icon: const Icon(
                          Icons.draw_rounded,
                          color: AppColors.neonGreen,
                        ),
                        label: Text(
                          _tr(
                            'Configurar Firma Digital Predeterminada',
                            'Set Up Default Digital Signature',
                            'Configurar Assinatura Digital Padrão',
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.surfaceCard,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. Community & Privacy Links
                      Material(
                        color: AppColors.surfaceCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            ListTile(
                              onTap: _shareApp,
                              leading: const Icon(
                                Icons.share_rounded,
                                color: AppColors.racingRed,
                              ),
                              title: Text(
                                _tr(
                                  'Compartir MotoAngleHUD',
                                  'Share MotoAngleHUD',
                                  'Compartilhar MotoAngleHUD',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.borderSubtle,
                            ),
                            ListTile(
                              onTap: _openPrivacyPolicy,
                              leading: const Icon(
                                Icons.privacy_tip_outlined,
                                color: AppColors.neonGreen,
                              ),
                              title: Text(
                                s.privacyPolicyBtn,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                s.appVersion,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.open_in_new_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 6. Welcome Landing Shortcut
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const WelcomeLandingScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.rocket_launch_rounded,
                          size: 18,
                          color: AppColors.electricCyan,
                        ),
                        label: Text(
                          _tr(
                            'Ver Pantalla de Presentación',
                            'View Welcome Landing Screen',
                            'Ver Tela de Boas-Vindas',
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 14),

                      ElevatedButton.icon(
                        key: const Key('btnSaveProfile'),
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(
                          s.saveSettingsBtn,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.neonGreen,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildLanguageOption({
    required String code,
    required String flag,
    required String label,
    required String currentLang,
  }) {
    final isSelected = currentLang.toLowerCase().startsWith(code);
    return InkWell(
      key: Key('langOption_$code'),
      onTap: () => _storage.setLocale(code),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.neonGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
