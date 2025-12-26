import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/qr_scan_result.dart';

/// Modern QR Scanner page using Clean Architecture
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool hasScanned = false;
  bool isTorchOn = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleTorch() {
    controller.toggleTorch();
    setState(() {
      isTorchOn = !isTorchOn;
    });
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    setState(() => hasScanned = true);
    _handleScanResult(code);
  }

  void _handleScanResult(String qrContent) {
    QRScanResult? result;

    // Parse QR content
    if (qrContent.startsWith('qrmenu://restaurant/')) {
      final restaurantId = qrContent.substring('qrmenu://restaurant/'.length);
      result = QRScanResult.restaurant(restaurantId);
      Navigator.of(context).pop(result);
    } else if (qrContent.startsWith('qrmenu://menu/')) {
      final menuId = qrContent.substring('qrmenu://menu/'.length);
      result = QRScanResult.menu(menuId);
      Navigator.of(context).pop(result);
    } else if (qrContent.startsWith('http://') || qrContent.startsWith('https://')) {
      // URL scanned - show add menu dialog
      _showAddMenuDialog(qrContent, isUrl: true);
    } else {
      // Plain text - show add menu dialog
      _showAddMenuDialog(qrContent, isUrl: false);
    }
  }

  void _showAddMenuDialog(String content, {required bool isUrl}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ErrorMessages.qrAddMenuTitle),
        content: Text(
          isUrl
              ? ErrorMessages.qrAddMenuUrlPrompt
              : ErrorMessages.qrAddMenuContentPrompt,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              setState(() => hasScanned = false); // Reset scanner
            },
            child: const Text(ErrorMessages.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              setState(() => hasScanned = false); // Reset scanner
            },
            child: const Text(ErrorMessages.rescan),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              final result = QRScanResult.addMenu(
                content: content,
                isUrl: isUrl,
              );
              Navigator.of(context).pop(result); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(ErrorMessages.qrAddMenuTitle),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${ErrorMessages.qrCameraErrorPrefix} ${error.errorDetails?.message ?? ErrorMessages.unknownError}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(ErrorMessages.close),
                    ),
                  ],
                ),
              );
            },
          ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  // Flash Toggle
                  IconButton(
                    icon: Icon(
                      isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: isTorchOn ? Colors.yellow : Colors.white,
                      size: 32,
                    ),
                    onPressed: _toggleTorch,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    ErrorMessages.qrInstructionTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    ErrorMessages.qrInstructionSubtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
