import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'service/wallet_service.dart';

// Pastikan file ini ada atau buat placeholder sementara
import 'top_up_confirmation_page.dart';

class TopUpAmountPage extends StatefulWidget {
  final String bankName;
  final String bankCode;

  const TopUpAmountPage({
    super.key,
    required this.bankName,
    required this.bankCode,
  });

  @override
  State<TopUpAmountPage> createState() => _TopUpAmountPageState();
}

class _TopUpAmountPageState extends State<TopUpAmountPage> {
  String _inputAmount = "";
  final double _minTopUp = 10000; // Minimal Top Up biasanya 10rb

  // Variable Data Real-Time
  double _currentBalance = 0.0;
  String _realUserName = "";
  bool _isLoadingBalance = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // ✅ Ambil Saldo & Nama (Sama seperti Withdraw)
  Future<void> _fetchUserData() async {
    final service = WalletService();
    try {
      final data = await service.getUserData();
      if (mounted) {
        setState(() {
          _currentBalance = data['balance']; // Pastikan key json sesuai
          _realUserName = data['name'];      // Pastikan key json sesuai
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        setState(() => _isLoadingBalance = false);
      }
    }
  }

  String _formatCurrency(String amountStr) {
    if (amountStr.isEmpty) return "Rp 0";
    double value = double.tryParse(amountStr) ?? 0;
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(value);
  }

  String _formatBalance(double amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  // Logic Keypad
  void _onKeyPress(String value) {
    setState(() {
      if (value == 'back') {
        if (_inputAmount.isNotEmpty) {
          _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
        }
      } else {
        if (_inputAmount.isEmpty && value == '0') return;
        if (_inputAmount.length < 10) { // Limit panjang angka
          _inputAmount += value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double numericAmount = double.tryParse(_inputAmount) ?? 0;

    // Validasi Top Up: Hanya cek minimal, TIDAK cek saldo maksimal (karena mau nambah)
    bool isValid = numericAmount >= _minTopUp && !_isLoadingBalance;

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: Stack(
        children: [
          // Background Texture
          Positioned.fill(
            child: Image.asset(
              'assets/subbg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.2),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Top Up Amount",
                            style: GoogleFonts.raleway(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // INFO CARD (Sama style dengan Withdraw)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2746),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00529C),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.bankName,
                                      style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Instant Top Up • ${_isLoadingBalance ? 'Loading...' : _realUserName}",
                                      style: GoogleFonts.inter(color: Colors.grey[300], fontSize: 12, letterSpacing: 1),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),
                        Text("Enter Amount", style: GoogleFonts.raleway(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),

                        // INPUT AREA
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1421),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white10, // Tidak ada validasi merah untuk Top Up
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Min. Top Up", style: GoogleFonts.raleway(color: Colors.grey, fontSize: 12)),
                                  Text("Rp 10.000", style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Display Input
                              Text(
                                _inputAmount.isEmpty ? "Rp 0" : _formatCurrency(_inputAmount),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),
                              Divider(color: Colors.grey[800], thickness: 0.5),
                              const SizedBox(height: 10),

                              // SALDO REAL TIME (Info Only)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Current Balance",
                                    style: GoogleFonts.raleway(color: Colors.grey[500], fontSize: 12),
                                  ),
                                  _isLoadingBalance
                                      ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent))
                                      : Text(
                                    _formatBalance(_currentBalance),
                                    style: GoogleFonts.inter(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // KEYPAD & BUTTON
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF050B18).withOpacity(0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          _buildKeyRow(['1', '2', '3']),
                          const SizedBox(height: 15),
                          _buildKeyRow(['4', '5', '6']),
                          const SizedBox(height: 15),
                          _buildKeyRow(['7', '8', '9']),
                          const SizedBox(height: 15),
                          _buildKeyRow(['', '0', 'back']),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // BUTTON CONTINUE
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: isValid ? const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF7B1FA2)]) : null,
                          color: isValid ? null : const Color(0xFF1E2746),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ElevatedButton(
                          onPressed: isValid
                              ? () {
                            // Navigasi ke Konfirmasi Top Up
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TopUpConfirmationPage(
                                  methodName: widget.bankName,
                                  accountName: _realUserName, // Pakai nama asli dari API
                                  nominalAmount: numericAmount,
                                  fee: 1000, // Biaya admin topup (contoh)
                                ),
                              ),
                            );
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text(
                            "Continue",
                            style: GoogleFonts.raleway(
                              color: isValid ? Colors.white : Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Keypad (Sama persis dengan withdraw)
  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) return const SizedBox(width: 80);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onKeyPress(key),
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: 80, height: 50, alignment: Alignment.center,
              child: key == 'back'
                  ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 22)
                  : Text(
                key,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}