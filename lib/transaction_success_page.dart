import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk fitur Copy Clipboard
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'home_page.dart'; // Pastikan path ini benar

class TransactionSuccessPage extends StatelessWidget {
  final dynamic amount; // ✅ Aman: Menerima String atau Double
  final String merchantName;
  final String transactionRef;
  final String note;
  final DateTime transactionDate;
  final String paymentSource;

  const TransactionSuccessPage({
    super.key,
    required this.amount,
    required this.merchantName,
    required this.transactionRef,
    required this.note,
    required this.transactionDate,
    required this.paymentSource,
  });

  // ✅ Helper: Format Rupiah Aman (Anti-Crash)
  String _formatCurrency(dynamic val) {
    if (val == null) return "Rp 0";
    double cleanVal = double.tryParse(val.toString()) ?? 0.0;
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(cleanVal);
  }

  // ✅ Helper: Format Tanggal
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date) + " WIB";
  }

  // ✅ Fitur: Salin Nomor Referensi
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: transactionRef));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Reference copied!", style: GoogleFonts.raleway()),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Icon Sukses Animasi (Optional: Bisa diganti Lottie kalau mau)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
                    ),

                    const SizedBox(height: 20),
                    Text("Payment Successful!", style: GoogleFonts.raleway(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Your transaction has been processed", style: GoogleFonts.raleway(color: Colors.grey, fontSize: 14)),

                    const SizedBox(height: 40),

                    // --- DETAIL UTAMA ---
                    Text("Total Amount", style: GoogleFonts.raleway(color: Colors.grey[400], fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                        _formatCurrency(amount),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)
                    ),

                    const SizedBox(height: 40),

                    // --- KARTU DETAIL ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2746),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow("Merchant", merchantName, isBold: true),
                          const Divider(color: Colors.white10, height: 30),
                          _buildDetailRow("Date", _formatDate(transactionDate)),
                          const SizedBox(height: 15),
                          _buildDetailRow("Source", paymentSource),
                          const SizedBox(height: 15),
                          _buildDetailRow("Note", note.isEmpty ? "-" : note),
                          const Divider(color: Colors.white10, height: 30),

                          // Row Khusus Reference Number dengan Tombol Copy
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Ref No.", style: GoogleFonts.raleway(color: Colors.grey)),
                              Row(
                                children: [
                                  Text(
                                      transactionRef.length > 15 ? "${transactionRef.substring(0, 10)}..." : transactionRef,
                                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _copyToClipboard(context),
                                    child: const Icon(Icons.copy, color: Colors.blueAccent, size: 16),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- TOMBOL HOME ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF0B1120),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 10,
                    shadowColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  onPressed: () {
                    // Kembali ke Home dan hapus semua history navigasi agar tidak bisa di-back
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                            (route) => false
                    );
                  },
                  child: Text("Done", style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper biar kodingan bersih
  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.raleway(color: Colors.grey)),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }
}