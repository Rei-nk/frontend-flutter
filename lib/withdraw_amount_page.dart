import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'withdraw_confirmation_page.dart';
import 'service/wallet_service.dart';

class WithdrawAmountPage extends StatefulWidget {
  final String bankName;
  final String accountNumber;
  final String accountName; // Ini nama dari halaman sebelumnya (Hardcode/Tidak dipakai lagi untuk transaksi)

  const WithdrawAmountPage({
    super.key,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  @override
  State<WithdrawAmountPage> createState() => _WithdrawAmountPageState();
}

class _WithdrawAmountPageState extends State<WithdrawAmountPage> {
  String _inputAmount = "";
  final double _minWithdraw = 50000;

  // Variable Data Real-Time
  double _currentBalance = 0.0;
  String _realUserName = ""; // ✅ Variabel baru untuk Nama Asli
  bool _isLoadingBalance = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // ✅ Panggil fungsi fetch data lengkap
  }

  // ✅ Fungsi Baru: Ambil Saldo & Nama sekaligus
  Future<void> _fetchUserData() async {
    final service = WalletService();
    // Pastikan WalletService sudah diupdate return Map (seperti kode di atas)
    final data = await service.getUserData();

    if (mounted) {
      setState(() {
        _currentBalance = data['balance'];
        _realUserName = data['name']; // Simpan nama asli (Sultan/Admin)
        _isLoadingBalance = false;
      });
      print("✅ Data Loaded: Saldo=$_currentBalance, Name=$_realUserName");
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

  void _onKeyPress(String value) {
    setState(() {
      if (value == 'back') {
        if (_inputAmount.isNotEmpty) {
          _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
        }
      } else {
        if (_inputAmount.isEmpty && value == '0') return;
        if (_inputAmount.length < 10) {
          _inputAmount += value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double numericAmount = double.tryParse(_inputAmount) ?? 0;

    // Validasi
    bool isOverBalance = numericAmount > _currentBalance;
    bool isValid = numericAmount >= _minWithdraw && !isOverBalance && !_isLoadingBalance;

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: Stack(
        children: [
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
                            "Withdraw Amount",
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
                        // BANK INFO CARD
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
                                child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
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
                                    // TAMPILKAN NAMA ASLI DI SINI (Opsional, agar user yakin)
                                    Text(
                                      "${widget.accountNumber} • ${_isLoadingBalance ? 'Loading...' : _realUserName}",
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
                              color: isOverBalance ? Colors.redAccent : Colors.white10,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Min. Withdraw", style: GoogleFonts.raleway(color: Colors.grey, fontSize: 12)),
                                  Text("Rp 50.000", style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Display Input
                              Text(
                                _inputAmount.isEmpty ? "Rp 0" : _formatCurrency(_inputAmount),
                                style: GoogleFonts.inter(
                                  color: isOverBalance ? Colors.redAccent : Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),
                              Divider(color: Colors.grey[800], thickness: 0.5),
                              const SizedBox(height: 10),

                              // SALDO REAL TIME (Dengan Loading)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isOverBalance ? "Insufficient Balance" : "Available Balance",
                                    style: GoogleFonts.raleway(
                                        color: isOverBalance ? Colors.redAccent : Colors.grey[500],
                                        fontSize: 12
                                    ),
                                  ),
                                  // Cek Loading
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
                            // Cek jika nama belum terload (safety check)
                            if (_realUserName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Data user belum lengkap, coba refresh."))
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WithdrawConfirmationPage(
                                  bankName: widget.bankName,
                                  accountNumber: widget.accountNumber,

                                  // 🔴 PERBAIKAN UTAMA:
                                  // Kirim _realUserName (Sultan) bukan widget.accountName (Rizky)
                                  accountName: _realUserName,

                                  nominalAmount: numericAmount,
                                  fee: 5000,
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