/// Trilingual Localization Strings for MotoAngleHUD Pro (SimpleAppsPG)
/// Supports Spanish (es), English (en), and Portuguese (pt)
class AppStrings {
  final String appTitle;
  final String appSubtitle;
  final String enterApp;
  final String startTrackSession;
  final String cancel;
  final String save;
  final String delete;
  final String close;
  final String resetPeaks;

  // Navigation Tabs
  final String tabCockpit;
  final String tabHudMirror;
  final String tabSavedSessions;
  final String tabSettings;

  // Cockpit & Telemetry
  final String cockpitTitle;
  final String leanAngleLabel;
  final String leftLean;
  final String rightLean;
  final String uprightStatus;
  final String peakLeftLabel;
  final String peakRightLabel;
  final String gForceBallTitle;
  final String lateralGLabel;
  final String longitudinalGLabel;
  final String totalGLabel;
  final String peakGLabel;
  final String calibrateZeroBtn;
  final String calibratedToast;
  final String simulationSectionTitle;
  final String simulationModeSwitch;
  final String simLeanSliderLabel;
  final String simLongGSliderLabel;
  final String simLatGSliderLabel;
  final String saveRideSessionBtn;

  // HUD Mirror & 0-100 Timer Tab
  final String hudMirrorTitle;
  final String mirrorModeToggle;
  final String mirrorModeActiveHint;
  final String mirrorModeNormalHint;
  final String timerSectionTitle;
  final String currentSpeedLabel;
  final String timer0to100Label;
  final String startRunBtn;
  final String stopRunBtn;
  final String resetRunBtn;
  final String estQuarterMileLabel;
  final String estPowerWeightLabel;
  final String simThrottleBoostLabel;

  // Saved Sessions & PDF Report
  final String savedSessionsTitle;
  final String noSessionsTitle;
  final String noSessionsDesc;
  final String exportPdfBtn;
  final String loadSessionBtn;
  final String deleteSessionConfirm;
  final String pdfReportTitle;
  final String pdfGeneratedDate;
  final String pdfRiderHeader;
  final String pdfTelemetryHeader;

  // Settings & Profile
  final String settingsTitle;
  final String proUnlockedTitle;
  final String proUnlockedSubtitle;
  final String languageSelectorTitle;
  final String riderProfileHeader;
  final String riderProfileDesc;
  final String riderNameLabel;
  final String motorcycleModelLabel;
  final String licensePlateLabel;
  final String tireCompoundLabel;
  final String trackClubLabel;
  final String saveSettingsBtn;
  final String settingsSavedSuccess;
  final String privacyPolicyBtn;
  final String appVersion;

  const AppStrings({
    required this.appTitle,
    required this.appSubtitle,
    required this.enterApp,
    required this.startTrackSession,
    required this.cancel,
    required this.save,
    required this.delete,
    required this.close,
    required this.resetPeaks,
    required this.tabCockpit,
    required this.tabHudMirror,
    required this.tabSavedSessions,
    required this.tabSettings,
    required this.cockpitTitle,
    required this.leanAngleLabel,
    required this.leftLean,
    required this.rightLean,
    required this.uprightStatus,
    required this.peakLeftLabel,
    required this.peakRightLabel,
    required this.gForceBallTitle,
    required this.lateralGLabel,
    required this.longitudinalGLabel,
    required this.totalGLabel,
    required this.peakGLabel,
    required this.calibrateZeroBtn,
    required this.calibratedToast,
    required this.simulationSectionTitle,
    required this.simulationModeSwitch,
    required this.simLeanSliderLabel,
    required this.simLongGSliderLabel,
    required this.simLatGSliderLabel,
    required this.saveRideSessionBtn,
    required this.hudMirrorTitle,
    required this.mirrorModeToggle,
    required this.mirrorModeActiveHint,
    required this.mirrorModeNormalHint,
    required this.timerSectionTitle,
    required this.currentSpeedLabel,
    required this.timer0to100Label,
    required this.startRunBtn,
    required this.stopRunBtn,
    required this.resetRunBtn,
    required this.estQuarterMileLabel,
    required this.estPowerWeightLabel,
    required this.simThrottleBoostLabel,
    required this.savedSessionsTitle,
    required this.noSessionsTitle,
    required this.noSessionsDesc,
    required this.exportPdfBtn,
    required this.loadSessionBtn,
    required this.deleteSessionConfirm,
    required this.pdfReportTitle,
    required this.pdfGeneratedDate,
    required this.pdfRiderHeader,
    required this.pdfTelemetryHeader,
    required this.settingsTitle,
    required this.proUnlockedTitle,
    required this.proUnlockedSubtitle,
    required this.languageSelectorTitle,
    required this.riderProfileHeader,
    required this.riderProfileDesc,
    required this.riderNameLabel,
    required this.motorcycleModelLabel,
    required this.licensePlateLabel,
    required this.tireCompoundLabel,
    required this.trackClubLabel,
    required this.saveSettingsBtn,
    required this.settingsSavedSuccess,
    required this.privacyPolicyBtn,
    required this.appVersion,
  });

  // ==========================================
  // SPANISH (es)
  // ==========================================
  static const es = AppStrings(
    appTitle: 'MOTOANGLE HUD',
    appSubtitle: 'Inclinómetro, Fuerza G 2D & Telemetría HUD Pro',
    enterApp: 'Entrar al Cockpit',
    startTrackSession: '+ Modo HUD Parabrisas',
    cancel: 'Cancelar',
    save: 'Guardar',
    delete: 'Eliminar',
    close: 'Cerrar',
    resetPeaks: 'Reiniciar Picos',
    tabCockpit: 'Cockpit',
    tabHudMirror: 'HUD Espejo',
    tabSavedSessions: 'Sesiones',
    tabSettings: 'Ajustes',
    cockpitTitle: 'Telemetría & Ángulo de Inclinación',
    leanAngleLabel: 'ÁNGULO DE INCLINACIÓN',
    leftLean: 'IZQ',
    rightLean: 'DER',
    uprightStatus: 'VERTICAL',
    peakLeftLabel: 'PICO IZQ',
    peakRightLabel: 'PICO DER',
    gForceBallTitle: 'ESFERA DE FUERZA G 2D (FRENADO / CURVA)',
    lateralGLabel: 'G Lateral',
    longitudinalGLabel: 'G Longitudinal',
    totalGLabel: 'G Total',
    peakGLabel: 'Pico G',
    calibrateZeroBtn: 'Calibrar Cero (0°)',
    calibratedToast: 'Sensor calibrado a posición cero (0°)',
    simulationSectionTitle: 'SIMULADOR DE PISTA & CONTROLES MANUALES',
    simulationModeSwitch: 'Modo Simulación Manual',
    simLeanSliderLabel: 'Inclinación Simulada (°)',
    simLongGSliderLabel: 'Aceleración / Frenado (m/s²)',
    simLatGSliderLabel: 'Aceleración Lateral (m/s²)',
    saveRideSessionBtn: 'Guardar Sesión de Rodada',
    hudMirrorTitle: 'HUD Parabrisas & Cronómetro 0-100',
    mirrorModeToggle: 'Modo Espejo Parabrisas (Reflejo X: -1)',
    mirrorModeActiveHint: 'MODO ESPEJO ACTIVO — Coloca el teléfono bajo la cúpula o parabrisas',
    mirrorModeNormalHint: 'Vista Directa — Activa el interruptor para reflejar en parabrisas',
    timerSectionTitle: 'CRONÓMETRO 0-100 KM/H & RENDIMIENTO',
    currentSpeedLabel: 'VELOCIDAD ESTIMADA',
    timer0to100Label: 'TIEMPO 0-100 KM/H',
    startRunBtn: 'Iniciar Lanzada',
    stopRunBtn: 'Detener',
    resetRunBtn: 'Reiniciar',
    estQuarterMileLabel: '1/4 Milla Est.',
    estPowerWeightLabel: 'Relación Potencia',
    simThrottleBoostLabel: 'Empuje de Aceleración (m/s²)',
    savedSessionsTitle: 'Sesiones de Telemetría Guardadas',
    noSessionsTitle: 'Sin sesiones registradas',
    noSessionsDesc: 'Guarda una sesión desde el Cockpit para exportar reportes PDF firmados.',
    exportPdfBtn: 'Exportar PDF',
    loadSessionBtn: 'Cargar en Cockpit',
    deleteSessionConfirm: '¿Deseas eliminar esta sesión de telemetría?',
    pdfReportTitle: 'REPORTE TÉCNICO DE TELEMETRÍA MOTOANGLE HUD',
    pdfGeneratedDate: 'Fecha de Sesión',
    pdfRiderHeader: 'DATOS DEL PILOTO, MOTOCICLETA Y NEUMÁTICOS',
    pdfTelemetryHeader: 'MÉTRICAS DE INCLINACIÓN, FUERZA G Y RENDIMIENTO',
    settingsTitle: 'Ajustes & Perfil del Piloto',
    proUnlockedTitle: 'Licencia Pro 100% Desbloqueada',
    proUnlockedSubtitle: 'Edición completa sin anuncios, sin suscripciones y 100% offline.',
    languageSelectorTitle: 'IDIOMA / LANGUAGE / IDIOMA',
    riderProfileHeader: 'PERFIL DEL PILOTO Y MOTOCICLETA',
    riderProfileDesc: 'Estos datos aparecerán en la cabecera de tus reportes PDF de rodada y telemetría.',
    riderNameLabel: 'Nombre del Piloto / Técnico',
    motorcycleModelLabel: 'Marca y Modelo de Motocicleta',
    licensePlateLabel: 'Número de Dorsal / Placa',
    tireCompoundLabel: 'Compuesto de Neumáticos / Presión',
    trackClubLabel: 'Circuito / Escudería / Club',
    saveSettingsBtn: 'Guardar Perfil y Ajustes',
    settingsSavedSuccess: 'Ajustes guardados correctamente',
    privacyPolicyBtn: 'Política de Privacidad',
    appVersion: 'MotoAngleHUD Pro v1.0.0 (SimpleAppsPG)',
  );

  // ==========================================
  // ENGLISH (en)
  // ==========================================
  static const en = AppStrings(
    appTitle: 'MOTOANGLE HUD',
    appSubtitle: 'Lean Angle Gauge, 2D G-Force & Pro Telemetry HUD',
    enterApp: 'Enter Cockpit',
    startTrackSession: '+ Windshield HUD Mode',
    cancel: 'Cancel',
    save: 'Save',
    delete: 'Delete',
    close: 'Close',
    resetPeaks: 'Reset Peaks',
    tabCockpit: 'Cockpit',
    tabHudMirror: 'HUD Mirror',
    tabSavedSessions: 'Sessions',
    tabSettings: 'Settings',
    cockpitTitle: 'Telemetry & Lean Angle Cockpit',
    leanAngleLabel: 'LEAN ANGLE',
    leftLean: 'LEFT',
    rightLean: 'RIGHT',
    uprightStatus: 'UPRIGHT',
    peakLeftLabel: 'PEAK LEFT',
    peakRightLabel: 'PEAK RIGHT',
    gForceBallTitle: '2D G-FORCE FRICTION CIRCLE (BRAKE / CORNER)',
    lateralGLabel: 'Lateral G',
    longitudinalGLabel: 'Longitudinal G',
    totalGLabel: 'Total G',
    peakGLabel: 'Peak G',
    calibrateZeroBtn: 'Calibrate Zero (0°)',
    calibratedToast: 'Sensor calibrated to zero position (0°)',
    simulationSectionTitle: 'TRACK SIMULATOR & MANUAL CONTROLS',
    simulationModeSwitch: 'Manual Track Simulation Mode',
    simLeanSliderLabel: 'Simulated Lean Angle (°)',
    simLongGSliderLabel: 'Accel / Braking (m/s²)',
    simLatGSliderLabel: 'Lateral Acceleration (m/s²)',
    saveRideSessionBtn: 'Save Ride Session',
    hudMirrorTitle: 'Windshield HUD & 0-100 Timer',
    mirrorModeToggle: 'Windshield Mirror Mode (ScaleX: -1)',
    mirrorModeActiveHint: 'MIRROR MODE ACTIVE — Place phone under windshield for reflection',
    mirrorModeNormalHint: 'Direct View — Toggle switch to mirror display onto windshield',
    timerSectionTitle: '0-100 KM/H TIMER & PERFORMANCE ESTIMATOR',
    currentSpeedLabel: 'ESTIMATED SPEED',
    timer0to100Label: '0-100 KM/H TIME',
    startRunBtn: 'Start Launch',
    stopRunBtn: 'Stop',
    resetRunBtn: 'Reset',
    estQuarterMileLabel: 'Est. 1/4 Mile',
    estPowerWeightLabel: 'Power Index',
    simThrottleBoostLabel: 'Launch Acceleration Boost (m/s²)',
    savedSessionsTitle: 'Saved Telemetry Sessions',
    noSessionsTitle: 'No saved sessions yet',
    noSessionsDesc: 'Save a ride session from the Cockpit to generate signed PDF telemetry reports.',
    exportPdfBtn: 'Export PDF',
    loadSessionBtn: 'Load in Cockpit',
    deleteSessionConfirm: 'Do you want to delete this telemetry session?',
    pdfReportTitle: 'MOTOANGLE HUD TECHNICAL TELEMETRY REPORT',
    pdfGeneratedDate: 'Session Date',
    pdfRiderHeader: 'RIDER, MOTORCYCLE & TIRE SETUP DATA',
    pdfTelemetryHeader: 'LEAN ANGLE, G-FORCE & PERFORMANCE METRICS',
    settingsTitle: 'Settings & Rider Profile',
    proUnlockedTitle: '100% Pro License Unlocked',
    proUnlockedSubtitle: 'Full paid edition with zero ads, zero paywalls, and 100% offline privacy.',
    languageSelectorTitle: 'LANGUAGE / IDIOMA',
    riderProfileHeader: 'RIDER & MOTORCYCLE PROFILE',
    riderProfileDesc: 'This information is embedded automatically in your exported PDF telemetry reports.',
    riderNameLabel: 'Rider / Telemetry Engineer Name',
    motorcycleModelLabel: 'Motorcycle Make & Model',
    licensePlateLabel: 'Race Number / Plate #',
    tireCompoundLabel: 'Tire Compound / Cold PSI',
    trackClubLabel: 'Circuit / Racing Team / Club',
    saveSettingsBtn: 'Save Profile & Settings',
    settingsSavedSuccess: 'Settings saved successfully',
    privacyPolicyBtn: 'Privacy Policy',
    appVersion: 'MotoAngleHUD Pro v1.0.0 (SimpleAppsPG)',
  );

  // ==========================================
  // PORTUGUESE (pt)
  // ==========================================
  static const pt = AppStrings(
    appTitle: 'MOTOANGLE HUD',
    appSubtitle: 'Inclinômetro, Força G 2D & Telemetria HUD Pro',
    enterApp: 'Entrar no Cockpit',
    startTrackSession: '+ Modo HUD Para-brisa',
    cancel: 'Cancelar',
    save: 'Salvar',
    delete: 'Excluir',
    close: 'Fechar',
    resetPeaks: 'Zerar Picos',
    tabCockpit: 'Cockpit',
    tabHudMirror: 'HUD Espelho',
    tabSavedSessions: 'Sessões',
    tabSettings: 'Ajustes',
    cockpitTitle: 'Telemetria & Ângulo de Inclinação',
    leanAngleLabel: 'ÂNGULO DE INCLINAÇÃO',
    leftLean: 'ESQ',
    rightLean: 'DIR',
    uprightStatus: 'VERTICAL',
    peakLeftLabel: 'PICO ESQ',
    peakRightLabel: 'PICO DIR',
    gForceBallTitle: 'ESFERA DE FORÇA G 2D (FRENAGEM / CURVA)',
    lateralGLabel: 'G Lateral',
    longitudinalGLabel: 'G Longitudinal',
    totalGLabel: 'G Total',
    peakGLabel: 'Pico G',
    calibrateZeroBtn: 'Calibrar Zero (0°)',
    calibratedToast: 'Sensor calibrado na posição zero (0°)',
    simulationSectionTitle: 'SIMULADOR DE PISTA & CONTROLES MANUAIS',
    simulationModeSwitch: 'Modo Simulação Manual',
    simLeanSliderLabel: 'Inclinação Simulada (°)',
    simLongGSliderLabel: 'Aceleração / Frenagem (m/s²)',
    simLatGSliderLabel: 'Aceleração Lateral (m/s²)',
    saveRideSessionBtn: 'Salvar Sessão de Pista',
    hudMirrorTitle: 'HUD Para-brisa & Cronômetro 0-100',
    mirrorModeToggle: 'Modo Espelho Para-brisa (Reflexo X: -1)',
    mirrorModeActiveHint: 'MODO ESPELHO ATIVO — Posicione o celular sob a bolha ou para-brisa',
    mirrorModeNormalHint: 'Visão Direta — Ative o botão para espelhar no para-brisa',
    timerSectionTitle: 'CRONÔMETRO 0-100 KM/H & DESEMPENHO',
    currentSpeedLabel: 'VELOCIDADE ESTIMADA',
    timer0to100Label: 'TEMPO 0-100 KM/H',
    startRunBtn: 'Iniciar Arrancada',
    stopRunBtn: 'Parar',
    resetRunBtn: 'Zerar',
    estQuarterMileLabel: '1/4 Milha Est.',
    estPowerWeightLabel: 'Índice Potência',
    simThrottleBoostLabel: 'Impulso de Aceleração (m/s²)',
    savedSessionsTitle: 'Sessões de Telemetria Salvas',
    noSessionsTitle: 'Nenhuma sessão salva',
    noSessionsDesc: 'Salve uma sessão no Cockpit para exportar relatórios PDF assinados.',
    exportPdfBtn: 'Exportar PDF',
    loadSessionBtn: 'Carregar no Cockpit',
    deleteSessionConfirm: 'Deseja excluir esta sessão de telemetria?',
    pdfReportTitle: 'RELATÓRIO TÉCNICO DE TELEMETRIA MOTOANGLE HUD',
    pdfGeneratedDate: 'Data da Sessão',
    pdfRiderHeader: 'DADOS DO PILOTO, MOTOCICLETA E PNEUS',
    pdfTelemetryHeader: 'MÉTRICAS DE INCLINAÇÃO, FORÇA G E DESEMPENHO',
    settingsTitle: 'Ajustes & Perfil do Piloto',
    proUnlockedTitle: 'Licença Pro 100% Desbloqueada',
    proUnlockedSubtitle: 'Edição completa sem anúncios, sem assinaturas e 100% offline.',
    languageSelectorTitle: 'IDIOMA / LANGUAGE',
    riderProfileHeader: 'PERFIL DO PILOTO E MOTOCICLETA',
    riderProfileDesc: 'Estes dados serão incluídos automaticamente nos seus relatórios PDF de telemetria.',
    riderNameLabel: 'Nome do Piloto / Engenheiro',
    motorcycleModelLabel: 'Marca e Modelo da Motocicleta',
    licensePlateLabel: 'Número de Competição / Placa',
    tireCompoundLabel: 'Composto de Pneus / Calibragem',
    trackClubLabel: 'Autódromo / Equipe / Moto Clube',
    saveSettingsBtn: 'Salvar Perfil e Ajustes',
    settingsSavedSuccess: 'Ajustes salvos com sucesso',
    privacyPolicyBtn: 'Política de Privacidade',
    appVersion: 'MotoAngleHUD Pro v1.0.0 (SimpleAppsPG)',
  );

  static AppStrings get(String localeCode) {
    if (localeCode.isEmpty) return es;
    final prefix = localeCode.toLowerCase().substring(0, localeCode.length >= 2 ? 2 : localeCode.length);
    switch (prefix) {
      case 'en':
        return en;
      case 'pt':
        return pt;
      case 'es':
      default:
        return es;
    }
  }
}
