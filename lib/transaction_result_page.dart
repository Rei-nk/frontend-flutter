import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'home_page.dart'; // Pastikan import ini benar

class TransactionResultPage extends StatelessWidget {
  final bool isSuccess;
  final String title;       // Contoh: "WITHDRAW SUCCESSFUL"
  final dynamic amount;     // Nominal
  final String reference;   // No Ref
  final String source;      // Contoh: "Fiat Wallet"
  final String destination; // Contoh: "BCA - 123456" (Pengganti Merchant)
  final String note;        // Catatan
  final DateTime date;      // Waktu Transaksi

  const TransactionResultPage({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.amount,
    required this.reference,
    required this.source,
    required this.destination,
    this.note = "-",
    required this.date,
  });

  // Helper Format Rupiah
  String _formatCurrency(dynamic val) {
    double cleanVal = double.tryParse(val.toString()) ?? 0.0;
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(cleanVal);
  }

  // Helper Format Tanggal
  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy, HH:mm:ss').format(date) + " WIB";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120), // Background gelap sesuai Payment
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // 1. ANIMASI IKON (Gabungan dari kode lama & baru)
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSuccess
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              border: Border.all(
                                  color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                                  width: 2
                              ),
                            ),
                            child: Icon(
                              isSuccess ? Icons.check_rounded : Icons.close_rounded,
                              color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // 2. JUDUL STATUS
                    Text(
                        title.toUpperCase(),
                        style: GoogleFonts.raleway(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        )
                    ),

                    const SizedBox(height: 30),

                    // 3. DETAIL TRANSAKSI (Gaya Struk)
                    _buildRow("No. Ref", reference),
                    const Divider(color: Colors.white10, height: 40),

                    Text("Total Amount", style: GoogleFonts.raleway(color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text(
                        _formatCurrency(amount),
                        style: GoogleFonts.inter(
                            color: isSuccess ? Colors.white : Colors.redAccent, // Merah jika gagal
                            fontSize: 32,
                            fontWeight: FontWeight.bold
                        )
                    ),

                    const SizedBox(height: 40),

                    // 4. KOTAK INFO BIRU
                    _buildBlueCard("SOURCE", source),
                    const SizedBox(height: 15),
                    _buildBlueCard("DESTINATION", destination), // Pengganti Merchant

                    const SizedBox(height: 30),
                    _buildDetailItem("Date", _formatDate(date)),
                    _buildDetailItem("Note", note.isEmpty ? "-" : note),

                    if (!isSuccess)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Transaction Failed. Please try again.",
                          style: GoogleFonts.raleway(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 5. TOMBOL BACK TO HOME (Logic Refresh)
            _buildHomeButton(context),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS (Sama persis dengan Payment Success) ---

  Widget _buildRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey)),
      Text(value, style: const TextStyle(color: Colors.white)),
    ],
  );

  Widget _buildBlueCard(String label, String value) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
        color: const Color(0xFF2E4C9D),
        borderRadius: BorderRadius.circular(10)
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        // Flexible agar teks panjang tidak error overflow
        Flexible(
            child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            )
        ),
      ],
    ),
  );

  Widget _buildDetailItem(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );

  Widget _buildHomeButton(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E4C9D), // Warna Biru
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () {
          // ✅ LOGIC PENTING: Reset Home agar saldo ter-update
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false
          );
        },
        child: const Text("Back to Home", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ),
  );
}