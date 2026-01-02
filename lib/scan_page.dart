import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'payment_confirmation_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isFlashOn = false;
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!_isScanning) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => _isScanning = false);
                  _handleQrCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // OVERLAY VISUAL
          Column(
            children: [
              Expanded(child: Container(color: Colors.black.withOpacity(0.5))),
              Row(
                children: [
                  Expanded(child: Container(color: Colors.black.withOpacity(0.5))),
                  Container(
                    width: 280, height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Container(width: 260, height: 1, color: Colors.redAccent.withOpacity(0.8)),
                    ),
                  ),
                  Expanded(child: Container(color: Colors.black.withOpacity(0.5))),
                ],
              ),
              Expanded(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 20),
                  child: Text("Arahkan ke QR Merchant", style: GoogleFonts.raleway(color: Colors.white70)),
                ),
              ),
            ],
          ),

          // TOMBOL HEADER
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text("Scan to Pay", style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () {
                      cameraController.toggleTorch();
                      setState(() => _isFlashOn = !_isFlashOn);
                    },
                    icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: _isFlashOn ? Colors.yellow : Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA BARU: MENDUKUNG FORMAT QRPAY:ID:NAMA:HARGA ---
  void _handleQrCode(String rawCode) async {
    await cameraController.stop();

    if (rawCode.startsWith("QRPAY:")) {
      // 1. SKENARIO QR DINAMIS (Format: QRPAY:ID:NAMA:HARGA)
      final parts = rawCode.split(':');

      if (parts.length >= 4) {
        String merchantId = parts[1];
        String merchantName = parts[2];
        double amount = double.tryParse(parts[3]) ?? 0;

        _navigateToConfirmation(rawCode, amount); // Kirim rawCode untuk di-parse lagi di sana
      } else {
        _showError("Format QRPAY tidak lengkap");
      }
    } else {
      // 2. SKENARIO QR STATIS / MANUAL (Bukan format QRPAY)
      // Langsung anggap sebagai ID Merchant saja
      _navigateToConfirmation(rawCode, 0);
    }
  }

  void _navigateToConfirmation(String rawData, double amount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentConfirmationPage(
          qrCodeId: rawData,
          amount: amount,
        ),
      ),
    ).then((_) => _resumeCamera());
  }

  void _resumeCamera() {
    cameraController.start();
    if (mounted) setState(() => _isScanning = true);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    _resumeCamera();
  }
}