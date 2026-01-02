import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'service/transaction_service.dart';
import 'transaction_result_page.dart'; // ✅ Pastikan import ini ada

class TopUpConfirmationPage extends StatefulWidget {
  final String methodName;    // Misal: "BCA Virtual Account"
  final String accountName;   // Nama User (Sultan)
  final double nominalAmount; // Input user (Misal: 50.000)
  final double fee;           // Fee (Misal: 1.000)

  const TopUpConfirmationPage({
    super.key,
    required this.methodName,
    required this.accountName,
    required this.nominalAmount,
    this.fee = 1000.0,
  });

  @override
  State<TopUpConfirmationPage> createState() => _TopUpConfirmationPageState();
}

class _TopUpConfirmationPageState extends State<TopUpConfirmationPage> {
  bool _isLoading = false;

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    final service = TransactionService();

    // 1. Panggil API Top Up
    final result = await service.topUp(
      amount: widget.nominalAmount,
      method: widget.methodName,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    bool isSuccess = result['success'];
    String message = result['message'];

    // 2. Siapkan Data untuk Struk
    // Dalam real app, Reference ID biasanya didapat dari 'result' backend.
    // Jika backend belum kirim ref, kita buat dummy dulu.
    String refId = result['data']?['reference'] ?? "TOP-${DateTime.now().millisecondsSinceEpoch}";

    // 3. Navigasi ke Halaman Hasil (Struk Baru)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionResultPage(
          isSuccess: isSuccess,
          title: isSuccess ? "TOP UP SUCCESSFUL" : "TOP UP FAILED",
          amount: widget.nominalAmount, // Jumlah yang masuk ke saldo
          reference: refId,
          source: widget.methodName, // BCA VA
          destination: "Fiat Wallet", // Masuk ke Wallet
          date: DateTime.now(),
          note: isSuccess ? "Top Up via Virtual Account" : message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🧮 LOGIKA TAMPILAN
    double totalPayment = widget.nominalAmount + widget.fee;
    double netReceived = widget.nominalAmount;

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050B18),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Confirmation",
          style: GoogleFonts.raleway(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: Column(
                  children: [
                    // KARTU SUMBER (Source)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2746),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: const Color(0xFF00529C).withOpacity(0.2),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.blueAccent, size: 24),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Top Up Method", style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(widget.methodName, style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("Destination: ${widget.accountName}", style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // RINCIAN BIAYA
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1421),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          // Baris 1: Nominal
                          _buildDetailRow("Top Up Amount", _formatCurrency(netReceived), isBold: true),
                          const SizedBox(height: 15),

                          // Baris 2: Fee
                          _buildDetailRow("Admin Fee", "+ ${_formatCurrency(widget.fee)}", color: Colors.orangeAccent),

                          const SizedBox(height: 15),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 15),

                          // Baris 3: Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Payment", style: GoogleFonts.raleway(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(_formatCurrency(totalPayment), style: GoogleFonts.inter(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text("(Amount to Transfer)", style: GoogleFonts.inter(color: Colors.grey, fontSize: 10)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BUTTON CONFIRM
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF7B1FA2)]),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("Confirm Top Up", style: GoogleFonts.raleway(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.raleway(color: Colors.grey[400], fontSize: 14)),
        Text(value, style: GoogleFonts.inter(
            color: color ?? Colors.white,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600
        )),
      ],
    );
  }
}