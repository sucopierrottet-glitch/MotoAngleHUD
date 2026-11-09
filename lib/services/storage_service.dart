import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../calculators/telemetry_calculator.dart';
import '../l10n/app_strings.dart';

/// Rider and motorcycle profile information stored locally
/// to automatically populate technical PDF telemetry reports.
class RiderProfile {
  final String riderName;
  final String motorcycleModel;
  final String licensePlate;
  final String tireCompound;
  final String trackClub;
  final String? defaultSignatureBase64;

  const RiderProfile({
    this.riderName = '',
    this.motorcycleModel = '',
    this.licensePlate = '',
    this.tireCompound = '',
    this.trackClub = '',
    this.defaultSignatureBase64,
  });

  Uint8List? get defaultSignatureBytes {
    if (defaultSignatureBase64 == null || defaultSignatureBase64!.isEmpty) {
      return null;
    }
    try {
      return base64Decode(defaultSignatureBase64!);
    } catch (_) {
      return null;
    }
  }

  RiderProfile copyWith({
    String? riderName,
    String? motorcycleModel,
    String? licensePlate,
    String? tireCompound,
    String? trackClub,
    String? defaultSignatureBase64,
    bool clearDefaultSignature = false,
  }) {
    return RiderProfile(
      riderName: riderName ?? this.riderName,
      motorcycleModel: motorcycleModel ?? this.motorcycleModel,
      licensePlate: licensePlate ?? this.licensePlate,
      tireCompound: tireCompound ?? this.tireCompound,
      trackClub: trackClub ?? this.trackClub,
      defaultSignatureBase64: clearDefaultSignature
          ? null
          : (defaultSignatureBase64 ?? this.defaultSignatureBase64),
    );
  }

  Map<String, dynamic> toJson() => {
        'riderName': riderName,
        'motorcycleModel': motorcycleModel,
        'licensePlate': licensePlate,
        'tireCompound': tireCompound,
        'trackClub': trackClub,
        'defaultSignatureBase64': defaultSignatureBase64,
      };

  factory RiderProfile.fromJson(Map<String, dynamic> json) {
    return RiderProfile(
      riderName: json['riderName'] as String? ?? '',
      motorcycleModel: json['motorcycleModel'] as String? ?? '',
      licensePlate: json['licensePlate'] as String? ?? '',
      tireCompound: json['tireCompound'] as String? ?? '',
      trackClub: json['trackClub'] as String? ?? '',
      defaultSignatureBase64: json['defaultSignatureBase64'] as String?,
    );
  }

  static const RiderProfile defaultProfile = RiderProfile(
    riderName: 'Carlos Mendoza',
    motorcycleModel: 'Yamaha YZF-R1M 1000cc',
    licensePlate: '#46 PRO',
    tireCompound: 'Pirelli Diablo Supercorsa SC1 (31/27 PSI)',
    trackClub: 'Autódromo Internacional / TrackDay Racing',
  );
}

/// Persistent record of a saved motorcycle telemetry ride session
class RideSession {
  final String id;
  final String title;
  final String trackName;
  final String notes;
  final DateTime timestamp;
  final TelemetryMetrics metrics;
  final double? zeroToHundredSeconds;
  final double estimatedQuarterMileSeconds;

  const RideSession({
    required this.id,
    required this.title,
    this.trackName = 'Circuito / Ruta',
    this.notes = '',
    required this.timestamp,
    required this.metrics,
    this.zeroToHundredSeconds,
    this.estimatedQuarterMileSeconds = 10.4,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'trackName': trackName,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
        'metrics': metrics.toJson(),
        'zeroToHundredSeconds': zeroToHundredSeconds,
        'estimatedQuarterMileSeconds': estimatedQuarterMileSeconds,
      };

  factory RideSession.fromJson(Map<String, dynamic> json) {
    final time = json['timestamp'] != null
        ? (DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now())
        : DateTime.now();

    final metricsMap = json['metrics'] as Map<String, dynamic>?;
    return RideSession(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? 'Track Session',
      trackName: json['trackName'] as String? ?? 'Circuito / Ruta',
      notes: json['notes'] as String? ?? '',
      timestamp: time,
      metrics: metricsMap != null
          ? TelemetryMetrics.fromJson(metricsMap)
          : TelemetryMetrics.initial(),
      zeroToHundredSeconds: (json['zeroToHundredSeconds'] as num?)?.toDouble(),
      estimatedQuarterMileSeconds:
          (json['estimatedQuarterMileSeconds'] as num?)?.toDouble() ?? 10.4,
    );
  }
}

/// Camino 1 Paid App StorageService (100% Pro Unlocked, no paywall)
class StorageService extends ChangeNotifier {
  static const String _keyLocale = 'motoanglehud_locale_code';
  static const String _keySessions = 'motoanglehud_saved_sessions';
  static const String _keyProfile = 'motoanglehud_rider_profile';

  static StorageService instance = StorageService();

  final SharedPreferences? _injectedPrefs;
  String _localeCode = 'es';
  bool _localeInitialized = false;

  StorageService([this._injectedPrefs]) {
    if (_injectedPrefs != null) {
      final saved = _injectedPrefs.getString(_keyLocale);
      if (saved != null && saved.isNotEmpty) {
        _localeCode = saved;
      } else if (!isTestEnvironment) {
        _localeCode = detectDeviceLocaleCode();
      }
      _localeInitialized = true;
    } else if (!isTestEnvironment) {
      _localeCode = detectDeviceLocaleCode();
    }
  }

  static bool get isTestEnvironment {
    try {
      final bindingName = WidgetsBinding.instance.runtimeType.toString();
      return bindingName.contains('Test');
    } catch (_) {
      return false;
    }
  }

  static String detectDeviceLocaleCode([ui.Locale? localeOverride]) {
    try {
      final locale = localeOverride ?? ui.PlatformDispatcher.instance.locale;
      final lang = locale.languageCode.toLowerCase();
      if (lang.startsWith('en')) return 'en';
      if (lang.startsWith('pt')) return 'pt';
      return 'es';
    } catch (_) {
      return 'es';
    }
  }

  Future<SharedPreferences> _getPrefs() async {
    final prefs = _injectedPrefs ?? await SharedPreferences.getInstance();
    if (!_localeInitialized) {
      _localeInitialized = true;
      final saved = prefs.getString(_keyLocale);
      if (saved != null && saved.isNotEmpty) {
        _localeCode = saved;
      } else if (!isTestEnvironment) {
        _localeCode = detectDeviceLocaleCode();
      }
    }
    return prefs;
  }

  Future<void> init({ui.Locale? deviceLocaleOverride}) async {
    final prefs = _injectedPrefs ?? await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyLocale);
    if (saved != null && saved.isNotEmpty) {
      _localeCode = saved;
    } else if (deviceLocaleOverride != null) {
      _localeCode = detectDeviceLocaleCode(deviceLocaleOverride);
    } else if (!isTestEnvironment) {
      _localeCode = detectDeviceLocaleCode();
    } else {
      _localeCode = 'es';
    }
    _localeInitialized = true;

    // Ensure at least one sample session is available on first launch if empty
    final existing = await getSavedSessions();
    if (existing.isEmpty) {
      final sampleSession = RideSession(
        id: 'sample-mugello-01',
        title: 'Tanda Libre #1 - Curva Rapida',
        trackName: 'Circuito GP / TrackDay',
        notes: 'Neumaticos en temperatura optima (82 C). Excelente traccion en salida.',
        timestamp: DateTime(2026, 10, 15, 10, 30),
        metrics: const TelemetryMetrics(
          leanAngleDeg: -48.5,
          absLeanAngleDeg: 48.5,
          direction: LeanDirection.left,
          peakLeftDeg: 51.2,
          peakRightDeg: 47.8,
          lateralG: -1.14,
          longitudinalG: 0.68,
          totalG: 1.33,
          peakG: 1.42,
          pitchDeg: -4.2,
        ),
        zeroToHundredSeconds: 3.15,
        estimatedQuarterMileSeconds: 10.05,
      );
      await saveSession(sampleSession);
    }
    notifyListeners();
  }

  String get localeCode => _localeCode;
  AppStrings get strings => AppStrings.get(_localeCode);

  /// Camino 1 Paid App: Always 100% Pro Unlocked
  bool get isProUnlocked => true;

  Future<void> setLocale(String code) async {
    if (_localeCode == code) return;
    _localeCode = code;
    _localeInitialized = true;
    final prefs = await _getPrefs();
    await prefs.setString(_keyLocale, code);
    notifyListeners();
  }

  Future<List<RideSession>> getSavedSessions() async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_keySessions);
      if (jsonStr == null || jsonStr.trim().isEmpty) return [];

      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is! List) return [];

      final List<RideSession> list = [];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          try {
            list.add(RideSession.fromJson(item));
          } catch (_) {}
        }
      }
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSession(RideSession session) async {
    final all = await getSavedSessions();
    final idx = all.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      all[idx] = session;
    } else {
      all.insert(0, session);
    }
    final prefs = await _getPrefs();
    await prefs.setString(
      _keySessions,
      jsonEncode(all.map((s) => s.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> deleteSession(String id) async {
    final all = await getSavedSessions();
    all.removeWhere((s) => s.id == id);
    final prefs = await _getPrefs();
    await prefs.setString(
      _keySessions,
      jsonEncode(all.map((s) => s.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<RiderProfile> getProfile() async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_keyProfile);
      if (jsonStr == null || jsonStr.trim().isEmpty) {
        return RiderProfile.defaultProfile;
      }
      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return RiderProfile.fromJson(decoded);
      }
      return RiderProfile.defaultProfile;
    } catch (_) {
      return RiderProfile.defaultProfile;
    }
  }

  Future<void> saveProfile(RiderProfile profile) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
    notifyListeners();
  }
}
