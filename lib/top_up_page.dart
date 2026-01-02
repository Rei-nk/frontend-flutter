import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_up_amount_page.dart'; // Import halaman selanjutnya

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  int _selectedMethodIndex = 0;

  // Data Dummy Virtual Account
  final List<Map<String, String>> _topUpMethods = [
    {
      "bank": "BCA Virtual Account",
      "desc": "Check Automatic",
      "code": "BCA",
      "color": "0xFF003875", // Biru BCA
    },
    {
      "bank": "BRI Virtual Account",
      "desc": "Check Automatic",
      "code": "BRI",
      "color": "0xFF00529C", // Biru BRI
    },
    {
      "bank": "Mandiri Virtual Account",
      "desc": "Check Automatic",
      "code": "MANDIRI",
      "color": "0xFFF39C12", // Kuning/Gold Mandiri
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                            "Top Up Method",
                            style: GoogleFonts.raleway(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balancing back button
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

                        // INFO CARD
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF151C35).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.bolt, color: Colors.yellowAccent, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Instant Top Up",
                                      style: GoogleFonts.raleway(
                                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Funds will be added to your Fiat Wallet instantly via Virtual Account.",
                                      style: GoogleFonts.raleway(
                                          color: Colors.grey[400], fontSize: 12, height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        Text(
                          "Select Method",
                          style: GoogleFonts.raleway(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // LIST METHODS
                        ...List.generate(_topUpMethods.length, (index) {
                          final method = _topUpMethods[index];
                          final isSelected = _selectedMethodIndex == index;
                          // Handle Mandiri color specifically or use tryParse logic
                          int colorVal = int.parse(method["color"]!);

                          return GestureDetector(
                            onTap: () => setState(() => _selectedMethodIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1E2746)
                                    : const Color(0xFF0F1421),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? Colors.blueAccent : Colors.white10,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Bank Logo Circle
                                  Container(
                                    width: 45, height: 45,
                                    decoration: BoxDecoration(
                                      color: Color(colorVal),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: method["code"] == "MANDIRI"
                                          ? const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20)
                                          : Text(
                                        method["code"]!,
                                        style: GoogleFonts.inter( // Angka/Code pakai Inter
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          method["bank"]!,
                                          style: GoogleFonts.raleway( // Huruf pakai Raleway
                                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          method["desc"]!,
                                          style: GoogleFonts.inter( // Info teknis pakai Inter
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, color: Colors.blueAccent, size: 24)
                                  else
                                    const Icon(Icons.circle_outlined, color: Colors.grey, size: 24),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BUTTON BOTTOM
          Positioned(
            left: 20, right: 20, bottom: 30,
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF7B1FA2)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ElevatedButton(
                onPressed: () {
                  final selectedBank = _topUpMethods[_selectedMethodIndex];

                  // Navigasi ke Halaman Input Nominal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopUpAmountPage(
                        bankName: selectedBank["bank"]!,
                        bankCode: selectedBank["code"]!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  "Continue",
                  style: GoogleFonts.raleway(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}