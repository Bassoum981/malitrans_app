import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../trip/domain/entities/active_trip.dart';
import '../controllers/ticket_validation_controller.dart';

class TicketScannerPage extends StatefulWidget {
  const TicketScannerPage({
    required this.trip,
    required this.controller,
    super.key,
  });

  final ActiveTrip trip;
  final TicketValidationController controller;

  @override
  State<TicketScannerPage> createState() => _TicketScannerPageState();
}

class _TicketScannerPageState extends State<TicketScannerPage> {
  final _scannerController = MobileScannerController(autoStart: false);
  bool _hasScanned = false;
  MobileScannerException? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCamera();
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Valider un billet',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Changer de caméra',
            onPressed: _scannerController.switchCamera,
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
          IconButton(
            tooltip: 'Lampe',
            onPressed: _scannerController.toggleTorch,
            icon: const Icon(Icons.flash_on_outlined),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, child) {
          if (widget.controller.ticket != null) {
            return _ValidationResult(
              message: 'Billet validé. Bon voyage !',
              icon: Icons.check_circle_outline,
              color: Colors.green,
              onScanAnother: _resetScanner,
            );
          }

          if (widget.controller.errorMessage != null) {
            return _ValidationResult(
              message: widget.controller.errorMessage!,
              icon: Icons.error_outline,
              color: AppColors.coral,
              onScanAnother: _resetScanner,
            );
          }

          if (_cameraError != null) {
            return _CameraPermissionState(
              message:
                  _cameraError!.errorCode ==
                      MobileScannerErrorCode.permissionDenied
                  ? 'L’autorisation de la caméra est nécessaire pour scanner un billet.'
                  : 'La caméra est indisponible sur cet appareil.',
              onRetry: _startCamera,
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  'Scannez le QR code du billet pour le trajet ${widget.trip.routeLabel}.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onDetect,
                      errorBuilder: (context, error) {
                        return _CameraPermissionState(
                          message:
                              error.errorCode ==
                                  MobileScannerErrorCode.permissionDenied
                              ? 'L’autorisation de la caméra est nécessaire pour scanner un billet.'
                              : 'La caméra est indisponible sur cet appareil.',
                          onRetry: _startCamera,
                        );
                      },
                    ),
                    IgnorePointer(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.mint, width: 3),
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                    if (widget.controller.isLoading)
                      const CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Positionnez le QR code dans le cadre.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _startCamera() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _cameraError = null;
    });

    try {
      await _scannerController.start();
    } on MobileScannerException catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cameraError = exception;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cameraError = const MobileScannerException(
          errorCode: MobileScannerErrorCode.genericError,
        );
      });
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned || widget.controller.isLoading) {
      return;
    }

    final qrCode = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    if (qrCode.isEmpty) {
      return;
    }

    _hasScanned = true;
    _scannerController.stop();
    await widget.controller.validate(tripId: widget.trip.id, qrCode: qrCode);
  }

  Future<void> _resetScanner() async {
    setState(() {
      _hasScanned = false;
    });
    widget.controller.clear();
    await _scannerController.start();
  }
}

class _CameraPermissionState extends StatelessWidget {
  const _CameraPermissionState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_outlined, size: 64),
            const SizedBox(height: 18),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Autoriser la caméra'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationResult extends StatelessWidget {
  const _ValidationResult({
    required this.message,
    required this.icon,
    required this.color,
    required this.onScanAnother,
  });

  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onScanAnother;

  @override
  Widget build(BuildContext context) {
    final ticket = context
        .findAncestorStateOfType<_TicketScannerPageState>()
        ?.widget
        .controller
        .ticket;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 76, color: color),
            const SizedBox(height: 22),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (ticket != null) ...[
              const SizedBox(height: 26),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _ResultRow(
                        label: 'Passager',
                        value: ticket.passengerName,
                      ),
                      _ResultRow(
                        label: 'Siège',
                        value: ticket.seatNumber.toString(),
                      ),
                      _ResultRow(
                        label: 'Montant',
                        value: '${ticket.price} FCFA',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onScanAnother,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scanner un autre billet'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
