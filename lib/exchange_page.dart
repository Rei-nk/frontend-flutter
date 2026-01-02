import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ==========================================================
// 1. PAGE: PILIH ASSET (SELECT ASSET)
// ==========================================================
class ExchangeSelectPage extends StatelessWidget {
  final List<dynamic> availableAssets;

  const ExchangeSelectPage({super.key, required this.availableAssets});

  // Helper Functions (Sama seperti di WalletPage untuk konsistensi)
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
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter aset yang balance-nya > 0 (Opsional, sesuaikan kebutuhan)
    final validAssets = availableAssets;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Overlay
          Positioned.fill(
            child: Image.asset(
              'assets/subbg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.3),
              errorBuilder: (c, o, s) => Container(color: Colors.black),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 15),
                      Text("Select Asset to Exchange", style: GoogleFonts.raleway(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Available Assets", style: GoogleFonts.raleway(color: Colors.grey, fontSize: 14)),
                ),
                const SizedBox(height: 10),

                // List Assets
                Expanded(
                  child: validAssets.isEmpty
                      ? Center(child: Text("No assets available", style: GoogleFonts.raleway(color: Colors.grey)))
                      : ListView.builder(
                    itemCount: validAssets.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      final asset = validAssets[index];
                      final symbol = asset['symbol'] ?? 'UNK';
                      final balance = double.tryParse(asset['balance'].toString()) ?? 0.0;
                      final priceIdr = double.tryParse(asset['estimated_idr'].toString()) ?? 0.0;

                      // Hitung harga per koin (Estimasi kasar dari total estimated_idr / balance)
                      // Jika balance 0, pakai default dummy atau 0
                      double pricePerCoin = (balance > 0) ? (priceIdr / balance) : 0;

                      // Siapkan data map yang bersih untuk dipass ke halaman berikutnya
                      final cleanAsset = {
                        'symbol': symbol,
                        'name': _getFullName(symbol),
                        'balance': balance,
                        'price': pricePerCoin, // Harga satuan (perkiraan)
                        'icon': _getIcon(symbol),
                        'color': _getColor(symbol),
                      };

                      return GestureDetector(
                        onTap: () {
                          // Pindah ke Halaman Amount
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExchangeAmountPage(asset: cleanAsset),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                                child: Icon(_getIcon(symbol), color: _getColor(symbol), size: 24),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_getFullName(symbol), style: GoogleFonts.raleway(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text(symbol, style: GoogleFonts.raleway(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("${balance.toStringAsFixed(4)} $symbol", style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================================
// 2. PAGE: MASUKKAN JUMLAH (AMOUNT PAGE)
// ==========================================================
class ExchangeAmountPage extends StatefulWidget {
  final Map<String, dynamic> asset;
  const ExchangeAmountPage({super.key, required this.asset});

  @override
  State<ExchangeAmountPage> createState() => _ExchangeAmountPageState();
}

class _ExchangeAmountPageState extends State<ExchangeAmountPage> {
  final TextEditingController _amountController = TextEditingController();
  double _inputAmount = 0.0;
  bool _isValid = false;
  String _errorText = "";

  void _validateInput(String value) {
    setState(() {
      _inputAmount = double.tryParse(value) ?? 0.0;
      double maxBalance = double.parse(widget.asset['balance'].toString());

      if (_inputAmount <= 0) {
        _isValid = false;
        _errorText = "";
      } else if (_inputAmount > maxBalance) {
        _isValid = false;
        _errorText = "Insufficient balance (Max: $maxBalance)";
      } else {
        _isValid = true;
        _errorText = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Estimasi IDR = Input * Harga Satuan
    double estimatedIDR = _inputAmount * (widget.asset['price'] ?? 0);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(color: Colors.black),
          Positioned.fill(
            child: Image.asset(
              'assets/subbg.png', fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.3),
              errorBuilder: (c, o, s) => Container(color: Colors.black),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      const Spacer(),
                      Text("Exchange Amount", style: GoogleFonts.raleway(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const SizedBox(width: 24),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Selected Asset Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.asset['icon'], color: widget.asset['color'], size: 20),
                        const SizedBox(width: 8),
                        Text("${widget.asset['name']} (${widget.asset['symbol']})", style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // INPUT FIELD (Font Inter)
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "0.0",
                      hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 40, fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    ),
                    onChanged: _validateInput,
                  ),

                  // Error Text
                  if (_errorText.isNotEmpty)
                    Text(_errorText, style: GoogleFonts.raleway(color: Colors.redAccent, fontSize: 14)),

                  const SizedBox(height: 10),

                  // Estimated Value
                  Text(
                    "≈ ${currencyFormat.format(estimatedIDR)}",
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  // Balance Info + Max Button
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Balance: ${widget.asset['balance']} ${widget.asset['symbol']}", style: GoogleFonts.raleway(color: Colors.grey)),
                        GestureDetector(
                          onTap: () {
                            _amountController.text = widget.asset['balance'].toString();
                            _validateInput(widget.asset['balance'].toString());
                          },
                          child: Text("MAX", style: GoogleFonts.raleway(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // CONTINUE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isValid ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExchangeConfirmationPage(
                              asset: widget.asset,
                              amount: _inputAmount,
                              estimatedIdr: estimatedIDR,
                            ),
                          ),
                        );
                      } : null, // Disable jika tidak valid
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        disabledBackgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text("Continue", style: GoogleFonts.raleway(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// 3. PAGE: CONFIRMATION
// ==========================================================
class ExchangeConfirmationPage extends StatelessWidget {
  final Map<String, dynamic> asset;
  final double amount;
  final double estimatedIdr;

  const ExchangeConfirmationPage({super.key, required this.asset, required this.amount, required this.estimatedIdr});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/subbg.png', fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.3), errorBuilder: (c, o, s) => Container(color: Colors.black)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios, color: Colors.white)),
                      const SizedBox(width: 15),
                      Text("Confirm Exchange", style: GoogleFonts.raleway(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Detail Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1E2746), Color(0xFF121212)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        _buildRow("From", "$amount ${asset['symbol']}", Colors.white),
                        const SizedBox(height: 15),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 15),
                        _buildRow("To (Estimate)", currencyFormat.format(estimatedIdr), Colors.greenAccent),
                        const SizedBox(height: 15),
                        _buildRow("Rate", "1 ${asset['symbol']} ≈ ${currencyFormat.format(asset['price'])}", Colors.grey),
                        const SizedBox(height: 15),
                        _buildRow("Fee", "Rp 0 (Free)", Colors.purpleAccent),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // CONFIRM BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // LOGIKA API BISA DITAMBAHKAN DISINI
                        // Untuk sekarang langsung ke sukses
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => ExchangeSuccessPage(amount: amount, symbol: asset['symbol'])),
                              (route) => route.isFirst, // Reset sampai Home
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shadowColor: Colors.purpleAccent.withOpacity(0.5),
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text("Confirm Exchange", style: GoogleFonts.raleway(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.raleway(color: Colors.grey, fontSize: 14)),
        Text(value, style: GoogleFonts.inter(color: valueColor, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ==========================================================
// 4. PAGE: SUCCESS
// ==========================================================
class ExchangeSuccessPage extends StatelessWidget {
  final double amount;
  final String symbol;

  const ExchangeSuccessPage({super.key, required this.amount, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset('assets/subbg.png', fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.3), errorBuilder: (c, o, s) => Container(color: Colors.black)),
          ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Sukses
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent.withOpacity(0.1),
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.greenAccent, size: 50),
                ),

                const SizedBox(height: 30),

                Text(
                  "Transaction Successfully!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "You have successfully exchanged\n$amount $symbol",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke Home (karena sudah di-reset di page sebelumnya)
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("Back to Wallet", style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}