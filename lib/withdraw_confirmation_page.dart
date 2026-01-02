import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'service/transaction_service.dart';
import 'transaction_result_page.dart';

class WithdrawConfirmationPage extends StatefulWidget {
  final String bankName;
  final String accountNumber;
  final String accountName;
  final double nominalAmount; // Input user (Misal: 50.000)
  final double fee;           // Fee (Misal: 5.000)

  const WithdrawConfirmationPage({
    super.key,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.nominalAmount,
    this.fee = 5000.0,
  });

  @override
  State<WithdrawConfirmationPage> createState() => _WithdrawConfirmationPageState();
}

class _WithdrawConfirmationPageState extends State<WithdrawConfirmationPage> {
  bool _isLoading = false;

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    final service = TransactionService();

    // 🔴 PERBAIKAN DI SINI:
    final result = await service.withdraw(
      amount: widget.nominalAmount,
      bankName: widget.bankName,
      accountNumber: widget.accountNumber,

      // ✅ TAMBAHKAN INI (Kirim nama 'Sultan' ke service)
      accountName: widget.accountName,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    bool isSuccess = result['success'];
    String message = result['message'];

    // ... (kode navigasi ke ResultPage tetap sama) ...
    // Di dalam withdraw_confirmation_page.dart, saat transaksi sukses:

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionResultPage(
          isSuccess: true,
          title: "WITHDRAWAL SUCCESSFUL",
          amount: widget.nominalAmount,
          reference: "TRX-${DateTime.now().millisecondsSinceEpoch}", // Dummy Ref
          source: "Fiat Wallet",
          destination: "${widget.bankName} - ${widget.accountNumber}", // Gabungan Bank & No Rek
          date: DateTime.now(),
          note: "Withdrawal Transaction",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🧮 LOGIKA TAMPILAN BARU
    // Total potong saldo = Apa yang diinput user (50.000)
    double totalDeducted = widget.nominalAmount;

    // Yang diterima bersih = Input - Fee (45.000)
    double netReceived = widget.nominalAmount - widget.fee;

    // Mencegah tampilan minus jika saldo input lebih kecil dari fee
    if (netReceived < 0) netReceived = 0;

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
                    // KARTU TUJUAN
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
                            child: const Icon(Icons.account_balance, color: Colors.blueAccent, size: 24),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Withdraw to", style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(widget.bankName, style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("${widget.accountNumber} • ${widget.accountName}", style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // RINCIAN (LOGIKA TAMPILAN DIUBAH DISINI)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1421),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          // Baris 1: Total yang akan ditarik (50.000)
                          _buildDetailRow("Total Withdrawal", _formatCurrency(totalDeducted), isBold: true),
                          const SizedBox(height: 15),

                          // Baris 2: Admin Fee (5.000)
                          _buildDetailRow("Admin Fee", "- ${_formatCurrency(widget.fee)}", color: Colors.redAccent),

                          const SizedBox(height: 15),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 15),

                          // Baris 3: Net yang diterima (45.000)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Net Received", style: GoogleFonts.raleway(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(_formatCurrency(netReceived), style: GoogleFonts.inter(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text("(Sent to Bank)", style: GoogleFonts.inter(color: Colors.grey, fontSize: 10)),
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
                          : Text("Confirm Withdraw", style: GoogleFonts.raleway(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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