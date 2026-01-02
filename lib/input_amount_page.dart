import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'payment_confirmation_page.dart';

class InputAmountPage extends StatefulWidget {
  final String merchantId;
  const InputAmountPage({super.key, required this.merchantId});

  @override
  State<InputAmountPage> createState() => _InputAmountPageState();
}

class _InputAmountPageState extends State<InputAmountPage> {
  final TextEditingController _amountController = TextEditingController();

  // Format Rupiah saat mengetik
  String _formatCurrency(String value) {
    if (value.isEmpty) return "";
    value = value.replaceAll(RegExp(r'[^0-9]'), ''); // Hapus non-angka
    if (value.isEmpty) return "";
    final number = double.parse(value);
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(number);
  }

  void _onContinue() {
    String cleanValue = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.isEmpty) return;
    double amount = double.parse(cleanValue);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentConfirmationPage(
          qrCodeId: widget.merchantId,
          amount: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        title: Text("Input Nominal", style: GoogleFonts.raleway(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Merchant ID: ${widget.merchantId}", style: GoogleFonts.raleway(color: Colors.grey)),
            const SizedBox(height: 40),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "Rp 0",
                hintStyle: TextStyle(color: Colors.grey[700]),
                border: InputBorder.none,
              ),
              onChanged: (val) {
                String formatted = _formatCurrency(val);
                if (formatted != _amountController.text) {
                  _amountController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: Text("Lanjut", style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}