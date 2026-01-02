import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ApiConfig.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];

  // Formatter Rupiah
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // --- FUNGSI AMBIL DATA (Logika dari temanmu + SharedPreferences) ---
  Future<void> _fetchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/transactions/history'),
        headers: {
          'x-user-id': userId.toString(),
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _transactions = json['data'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Gagal: ${response.statusCode}');
      }
    } catch (e) {
      print("🔥 Error Fetch History: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18), // Warna gelap QryptoPay
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("History", style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                : _transactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                // Data diambil dari yang terbaru (reversed)
                final trx = _transactions[(_transactions.length - 1) - index];
                return _buildTransactionCard(trx);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text("No transactions found", style: GoogleFonts.raleway(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(dynamic trx) {
    final bool isSuccess = trx['status'] == 'SUCCESS';

    // LOGIKA PENENTUAN MERCHANT:
    // Sesuai kode temanmu, merchant ada di 'title'
    final String merchantName = trx['title'] ?? trx['description'] ?? 'Unknown Merchant';
    final String note = trx['note'] ?? '-';
    final String dateText = trx['date'] ?? trx['created_at'] ?? '';
    final double amount = double.tryParse(trx['amount'].toString()) ?? 0;

    // Menentukan Icon & Warna berdasarkan tipe/deskripsi
    bool isIncoming = merchantName.toLowerCase().contains('deposit') ||
        merchantName.toLowerCase().contains('topup');

    Color accentColor = isIncoming ? Colors.greenAccent : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2746).withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncoming ? Icons.arrow_downward : Icons.store,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 15),

          // Informasi Tengah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchantName, // TAMPILKAN NAMA MERCHANT DI SINI
                  style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  note,
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 10),
                ),
              ],
            ),
          ),

          // Nominal Kanan
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isIncoming ? '+' : '-'} ${currencyFormatter.format(amount)}",
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  isSuccess ? "LUNAS" : "PENDING",
                  style: TextStyle(
                    color: isSuccess ? Colors.green : Colors.orange,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}