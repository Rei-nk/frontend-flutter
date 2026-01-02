import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction_success_page.dart';
import 'ApiConfig.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final String? qrCodeId; // Format: QRPAY:ID:NAMA:KOTA
  final double amount;

  const PaymentConfirmationPage({
    super.key,
    this.qrCodeId,
    required this.amount,
  });

  @override
  State<PaymentConfirmationPage> createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  bool _isLoading = false;
  final TextEditingController _noteController = TextEditingController();

  // Data Saldo & Aset
  double _currentFiatBalance = 0.0;
  List<dynamic> _myCryptoAssets = [];
  String? _selectedCryptoAsset;

  // Data Merchant
  String _merchantName = "Loading...";
  String _merchantCity = "";
  String _parsedMerchantId = "0";

  @override
  void initState() {
    super.initState();
    _parseQRData();
    _fetchCurrentBalance();
    _fetchCryptoAssets();
  }

  // --- 1. PARSING DATA QR CODE ---
  void _parseQRData() {
    try {
      // Format: QRPAY:15:KopiKenangan:Jakarta
      if (widget.qrCodeId != null && widget.qrCodeId!.contains(':')) {
        List<String> parts = widget.qrCodeId!.split(':');
        if (parts.length >= 4) {
          setState(() {
            _parsedMerchantId = parts[1];
            _merchantName = parts[2];
            _merchantCity = parts[3];
          });
        } else {
          // Fallback Format Standar
          setState(() {
            _parsedMerchantId = widget.qrCodeId!;
            _merchantName = "Merchant ID: ${widget.qrCodeId}";
          });
        }
      }
    } catch (e) {
      debugPrint("Error parsing QR: $e");
    }
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  // --- 2. AMBIL SALDO FIAT (SAFE PARSING ✅) ---
  Future<void> _fetchCurrentBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) return;

      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            // ✅ FIX: Konversi ke String dulu, baru ke Double
            _currentFiatBalance = double.tryParse(data['data']['balance'].toString()) ?? 0.0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching fiat: $e");
    }
  }

  // --- 3. AMBIL ASET CRYPTO ---
  Future<void> _fetchCryptoAssets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) return;

      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/wallets/crypto/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> assets = data['data'] ?? [];

        if (mounted) {
          setState(() {
            _myCryptoAssets = assets;
            // Pilih aset pertama otomatis jika ada
            if (_myCryptoAssets.isNotEmpty) {
              _selectedCryptoAsset = _myCryptoAssets[0]['symbol'];
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching crypto: $e");
    }
  }

  // --- LOGIKA TOMBOL CONFIRM ---
  void _onConfirmPressed() {
    // Cek apakah saldo Fiat cukup
    if (_currentFiatBalance >= widget.amount) {
      _processPayment(isSplit: false); // Bayar Full Fiat
    } else {
      _showInsufficientBalanceModal(); // Bayar Split (Fiat + Crypto)
    }
  }

  // --- 4. MODAL SPLIT PAYMENT ---
  void _showInsufficientBalanceModal() {
    double shortage = widget.amount - _currentFiatBalance;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Color(0xFF151C35),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                border: Border(top: BorderSide(color: Color(0xFF2E4C9D), width: 2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 15),
                      Text("INSUFFICIENT BALANCE", style: GoogleFonts.raleway(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Saldo kurang ${_formatCurrency(shortage)}.\nGunakan crypto untuk membayar sisanya?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 25),

                  // Dropdown Crypto Asset
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(color: const Color(0xFF2E4C9D), borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCryptoAsset,
                        hint: Text("Pilih Aset", style: GoogleFonts.raleway(color: Colors.white)),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        dropdownColor: const Color(0xFF2E4C9D),
                        isExpanded: true,
                        items: _myCryptoAssets.map<DropdownMenuItem<String>>((asset) {
                          String symbol = asset['symbol'];
                          // ✅ FIX: Safe parsing untuk estimasi IDR
                          double idrVal = double.tryParse(asset['estimated_idr'].toString()) ?? 0;
                          return DropdownMenuItem<String>(
                            value: symbol,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(symbol, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text(_formatCurrency(idrVal), style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() => _selectedCryptoAsset = value);
                          setState(() => _selectedCryptoAsset = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedCryptoAsset == null ? null : () {
                        Navigator.pop(context);
                        _processPayment(isSplit: true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      child: Text("Pay with Auto-Convert", style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- 5. EKSEKUSI PEMBAYARAN KE API (UPDATED ✅) ---
  Future<void> _processPayment({required bool isSplit}) async {
    setState(() { _isLoading = true; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) throw Exception("Sesi habis. Silakan login ulang.");

      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/transactions/pay');

      Map<String, dynamic> body = {
        "user_id": userId,
        "merchant_id": int.tryParse(_parsedMerchantId) ?? 0,
        "amount": widget.amount,
        "note": _noteController.text,
        "is_split": isSplit,
        "crypto_asset": isSplit ? _selectedCryptoAsset : null,
        "fiat_used": isSplit ? _currentFiatBalance : widget.amount,
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json" // Header penting untuk API
        },
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          final data = responseBody['data'] ?? {};

          // --- ✅ FIX UTAMA: Safe Parsing Response Backend ---
          // Mengubah apapun yang dikirim backend menjadi String dulu, baru diparse ke double.
          double finalAmount = double.tryParse(data['amount'].toString()) ?? widget.amount;
          String ref = data['reference']?.toString() ?? "TRX-${DateTime.now().millisecondsSinceEpoch}";
          // ----------------------------------------------------

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionSuccessPage(
                amount: finalAmount, // Variable sudah aman
                merchantName: _merchantName,
                transactionRef: ref,
                note: _noteController.text,
                transactionDate: DateTime.now(),
                paymentSource: isSplit ? "AUTO-CONVERT (FIAT + $_selectedCryptoAsset)" : "FIAT WALLET",
              ),
            ),
                (route) => false,
          );
        }
      } else {
        throw Exception(responseBody['message'] ?? 'Transaksi Gagal');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("Gagal: ${e.toString().replaceAll("Exception: ", "")}"),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        centerTitle: true,
        title: Text("KONFIRMASI", style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // --- MERCHANT INFO ---
            Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: const Color(0xFF1E2746), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.store, color: Colors.blueAccent, size: 28),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_merchantName, style: GoogleFonts.raleway(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("$_merchantCity (ID: $_parsedMerchantId)", style: GoogleFonts.raleway(color: Colors.grey[600], fontSize: 12)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 30),

            // --- DETAIL TAGIHAN ---
            _buildDetailRow("Nominal", _formatCurrency(widget.amount)),
            const SizedBox(height: 10),
            _buildDetailRow("Admin Fees", "Rp 0"),
            const SizedBox(height: 15),
            Divider(color: Colors.grey[800]),
            const SizedBox(height: 15),

            // --- CARD TOTAL & NOTE ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151C35),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Pay", style: GoogleFonts.raleway(color: Colors.grey, fontSize: 16)),
                      Text(
                          _formatCurrency(widget.amount),
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFF0B1120), borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _noteController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Add note (optional)...",
                        hintStyle: GoogleFonts.raleway(color: Colors.grey[600], fontSize: 14),
                        prefixIcon: Icon(Icons.edit, color: Colors.grey[600], size: 18),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),
            Align(alignment: Alignment.centerLeft, child: Text("Payment Source", style: GoogleFonts.raleway(color: Colors.grey))),
            const SizedBox(height: 10),

            // --- SUMBER DANA (FIAT) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2E4C9D), Color(0xFF1E2746)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("FIAT WALLET", style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                      _formatCurrency(_currentFiatBalance),
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- TOMBOL KONFIRMASI ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onConfirmPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  shadowColor: Colors.blueAccent.withOpacity(0.5),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("CONFIRM PAYMENT", style: GoogleFonts.raleway(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.raleway(color: Colors.grey, fontSize: 15)),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}