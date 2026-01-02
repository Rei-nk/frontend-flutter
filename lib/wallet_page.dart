import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'scan_page.dart';
import 'ApiConfig.dart';
import 'withdraw_page.dart';
import 'exchange_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  // --- STATE VARIABLES ---
  double _fiatBalance = 0.0;
  double _totalCryptoBalanceIDR = 0.0;
  List<dynamic> _cryptoAssets = [];
  bool _isLoading = true;
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _refreshAllData();
  }

  Future<void> _refreshAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchFiatData(),
        _fetchCryptoAssets(),
      ]);
    } catch (e) {
      debugPrint("Error Refreshing Data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 1. AMBIL SALDO FIAT
  Future<void> _fetchFiatData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) return;

      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data'];

        if (mounted) {
          setState(() {
            _fiatBalance = double.tryParse(userData['balance'].toString()) ?? 0.0;
            _userName = userData['name']?.toString() ?? "User";
          });
        }
      }
    } catch (e) {
      debugPrint("Error Fetch Fiat: $e");
    }
  }

  // 2. AMBIL ASET CRYPTO
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

        double totalVal = 0.0;
        for (var asset in assets) {
          totalVal += double.tryParse(asset['estimated_idr'].toString()) ?? 0.0;
        }

        if (mounted) {
          setState(() {
            _cryptoAssets = assets;
            _totalCryptoBalanceIDR = totalVal;
          });
        }
      }
    } catch (e) {
      debugPrint("Error Fetch Crypto: $e");
    }
  }

  // Helper Simbol ke Nama
  String _getFullName(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'ETH': return 'ETHEREUM';
      case 'BTC': return 'BITCOIN';
      case 'SOL': return 'SOLANA';
      default: return symbol.toUpperCase();
    }
  }

  IconData _getIcon(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'ETH': return Icons.diamond_outlined;
      case 'BTC': return Icons.currency_bitcoin;
      case 'SOL': return Icons.blur_on;
      default: return Icons.monetization_on;
    }
  }

  Color _getColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'ETH': return Colors.blue;
      case 'BTC': return Colors.orange;
      case 'SOL': return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Hitam
        Container(color: Colors.black),

        // Background Image (Opasitas Rendah)
        Positioned.fill(
          child: Image.asset(
            'assets/subbg.png',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.3),
            errorBuilder: (c, o, s) => Container(color: Colors.black),
          ),
        ),

        // Konten Utama
        SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshAllData,
            color: Colors.purpleAccent,
            backgroundColor: const Color(0xFF1E2746),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  WalletHeader(userName: _userName),

                  const SizedBox(height: 30),

                  // BALANCE CARD
                  _isLoading && _fiatBalance == 0
                      ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                      : BalanceCard(
                    fiatBalance: _fiatBalance,
                    cryptoBalance: _totalCryptoBalanceIDR,
                  ),

                  const SizedBox(height: 30),

                  // --- UPDATED SECTION: TITLE & EXCHANGE BUTTON ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your Assets",
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // TOMBOL EXCHANGE
                      GestureDetector(
                        onTap: () {
                          // Pass data aset yang ada ke halaman exchange
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExchangeSelectPage(
                                availableAssets: _cryptoAssets, // Kirim data aset API
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.purpleAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purpleAccent, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.swap_horiz, color: Colors.purpleAccent, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                "Exchange",
                                style: GoogleFonts.raleway(
                                  color: Colors.purpleAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // --- END UPDATED SECTION ---

                  const SizedBox(height: 15),

                  // LIST ASET
                  _buildAssetList(),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetList() {
    if (_cryptoAssets.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.grey[700], size: 50),
              const SizedBox(height: 10),
              Text("No crypto assets yet", style: GoogleFonts.raleway(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _cryptoAssets.length,
      itemBuilder: (context, index) {
        final asset = _cryptoAssets[index];
        final symbol = asset['symbol'] ?? "";

        // Parsing
        final balance = double.tryParse(asset['balance'].toString()) ?? 0.0;
        final idrVal = double.tryParse(asset['estimated_idr'].toString()) ?? 0.0;
        final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

        return AssetTile(
          name: _getFullName(symbol),
          amount: "${balance.toStringAsFixed(4)} $symbol",
          value: format.format(idrVal),
          color: _getColor(symbol),
          iconData: _getIcon(symbol),
        );
      },
    );
  }
}

// ... (Widget pendukung seperti WalletHeader, BalanceCard, AssetTile, HeaderButton tetap sama seperti sebelumnya) ...
// Sertakan widget pendukung yang ada di kode lama Anda di bawah ini
// (Saya tidak menulis ulang agar jawaban tidak terlalu panjang, tapi pastikan class-nya ada di file ini)

class WalletHeader extends StatelessWidget {
  final String userName;
  const WalletHeader({super.key, required this.userName});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello,", style: GoogleFonts.raleway(color: Colors.grey, fontSize: 12)),
            Text(userName, style: GoogleFonts.raleway(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const Spacer(),
        HeaderButton(text: "TopUp", onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("TopUp Coming Soon"))); }),
        const SizedBox(width: 8),
        HeaderButton(text: "Withdraw", onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const WithdrawPage())); }),
      ],
    );
  }
}

class BalanceCard extends StatelessWidget {
  final double fiatBalance;
  final double cryptoBalance;
  const BalanceCard({super.key, required this.fiatBalance, required this.cryptoBalance});

  @override
  Widget build(BuildContext context) {
    final double totalBalance = fiatBalance + cryptoBalance;
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF7B1FA2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total Balance (Fiat + Crypto)", style: GoogleFonts.raleway(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 5),
          Text(format.format(totalBalance), style: GoogleFonts.inter(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Fiat:", style: GoogleFonts.raleway(color: Colors.white70, fontSize: 13)),
              Text(format.format(fiatBalance), style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Crypto:", style: GoogleFonts.raleway(color: Colors.white70, fontSize: 13)),
              Text(format.format(cryptoBalance), style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class AssetTile extends StatelessWidget {
  final String name;
  final String amount;
  final String value;
  final IconData iconData;
  final Color color;
  const AssetTile({super.key, required this.name, required this.amount, required this.value, required this.iconData, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1)))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(iconData, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: GoogleFonts.raleway(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(amount, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
          ]),
        ],
      ),
    );
  }
}

class HeaderButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const HeaderButton({super.key, required this.text, required this.onTap});
  @override
  State<HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<HeaderButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.purpleAccent : Colors.black.withOpacity(0.5),
          border: Border.all(color: Colors.purpleAccent),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isPressed ? [BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 10)] : [],
        ),
        child: Text(widget.text, style: GoogleFonts.raleway(color: Colors.white, fontSize: 12, fontWeight: _isPressed ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}