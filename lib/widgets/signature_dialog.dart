import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SignatureDialogResult {
  final Uint8List signatureBytes;
  final String riderName;
  final String motorcycleModel;
  final String licensePlate;

  const SignatureDialogResult({
    required this.signatureBytes,
    required this.riderName,
    required this.motorcycleModel,
    required this.licensePlate,
  });
}

class SignatureDialog extends StatefulWidget {
  final String initialRiderName;
  final String initialMotoModel;
  final String initialPlate;

  const SignatureDialog({
    super.key,
    this.initialRiderName = 'Carlos Mendoza',
    this.initialMotoModel = 'Yamaha YZF-R1M 1000cc',
    this.initialPlate = '#46 PRO',
  });

  static Future<SignatureDialogResult?> show(
    BuildContext context, {
    String? riderName,
    String? motorcycleModel,
    String? licensePlate,
  }) {
    return showDialog<SignatureDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SignatureDialog(
        initialRiderName:
            (riderName != null && riderName.isNotEmpty) ? riderName : 'Carlos Mendoza',
        initialMotoModel: (motorcycleModel != null && motorcycleModel.isNotEmpty)
            ? motorcycleModel
            : 'Yamaha YZF-R1M 1000cc',
        initialPlate:
            (licensePlate != null && licensePlate.isNotEmpty) ? licensePlate : '#46 PRO',
      ),
    );
  }

  @override
  State<SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  late final SignatureController _controller;
  late final TextEditingController _nameController;
  late final TextEditingController _motoController;
  late final TextEditingController _plateController;

  bool _isExporting = false;
  String? _validationError;

  String _tr(String es, String en, String pt) {
    final lang = StorageService.instance.localeCode;
    if (lang.startsWith('en')) return en;
    if (lang.startsWith('pt')) return pt;
    return es;
  }

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3.0,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
      onDrawEnd: () {
        if (_validationError != null) {
          setState(() => _validationError = null);
        }
      },
    );
    _nameController = TextEditingController(text: widget.initialRiderName);
    _motoController = TextEditingController(text: widget.initialMotoModel);
    _plateController = TextEditingController(text: widget.initialPlate);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _motoController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_controller.isEmpty) {
      setState(() {
        _validationError = _tr(
          'Por favor dibuja tu firma en el recuadro antes de confirmar.',
          'Please draw your signature on the pad before confirming.',
          'Por favor desenhe sua assinatura no quadro antes de confirmar.',
        );
      });
      return;
    }

    setState(() => _isExporting = true);
    try {
      final pngBytes = await _controller.toPngBytes();
      if (!mounted) return;
      if (pngBytes == null || pngBytes.isEmpty) {
        setState(() {
          _isExporting = false;
          _validationError = _tr(
            'No se pudo exportar la firma. Intenta de nuevo.',
            'Failed to extract signature image. Please redraw.',
            'Não foi possível exportar a assinatura. Tente novamente.',
          );
        });
        return;
      }

      Navigator.of(context).pop(
        SignatureDialogResult(
          signatureBytes: pngBytes,
          riderName: _nameController.text.trim().isEmpty
              ? 'Rider / Telemetry Engineer'
              : _nameController.text.trim(),
          motorcycleModel: _motoController.text.trim().isEmpty
              ? 'Sport Motorcycle'
              : _motoController.text.trim(),
          licensePlate: _plateController.text.trim().isEmpty
              ? '#01'
              : _plateController.text.trim(),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _validationError = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = StorageService.instance.strings;

    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.draw_rounded,
                      color: AppColors.neonGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tr(
                            'Firma Digital de Telemetría',
                            'Telemetry Digital Sign-Off',
                            'Assinatura Digital de Telemetria',
                          ),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _tr(
                            'Certificación para Reporte Técnico PDF',
                            'Certification for Technical PDF Report',
                            'Certificação para Relatório Técnico PDF',
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: s.riderNameLabel,
                  prefixIcon: const Icon(Icons.sports_motorsports_rounded,
                      color: AppColors.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _motoController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: s.motorcycleModelLabel,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _plateController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: s.licensePlateLabel,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _tr('Panel de Firma Táctil', 'Touch Signature Pad',
                        'Painel de Assinatura'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _controller.clear(),
                    icon: const Icon(Icons.refresh,
                        size: 16, color: AppColors.cautionAmber),
                    label: Text(
                      _tr('Limpiar', 'Clear', 'Limpar'),
                      style: const TextStyle(
                          color: AppColors.cautionAmber, fontSize: 12),
                    ),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _validationError != null
                          ? AppColors.racingRed
                          : AppColors.borderHighContrast,
                      width: 1.5,
                    ),
                  ),
                  child: Signature(
                    controller: _controller,
                    height: 160,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              if (_validationError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _validationError!,
                  style: const TextStyle(
                      color: AppColors.racingRed, fontSize: 12),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: Text(s.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isExporting ? null : _handleConfirm,
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: Text(
                        _tr('Confirmar Firma', 'Confirm Signature',
                            'Confirmar Assinatura'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
