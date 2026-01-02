import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'withdraw_amount_page.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  int _selectedMethodIndex = 0;

  // --- PERBAIKAN DI SINI (Menambahkan "name") ---
  final List<Map<String, String>> _withdrawMethods = [
    {
      "bank": "Bank Rakyat Indonesia (BRI)",
      "number": "12345678899",
      "code": "BRI",
      "color": "0xFF00529C",
      "name": "MUHAMMAD RIZKY" // Pastikan field 'name' ini ada!
    },
    {
      "bank": "Bank Central Asia (BCA)",
      "number": "8899112233",
      "code": "BCA",
      "color": "0xFF003875",
      "name": "MUHAMMAD RIZKY" // Pastikan field 'name' ini ada!
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
                            "Withdraw Method",
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
                              const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Withdrawal Information",
                                      style: GoogleFonts.raleway(
                                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Funds will be deducted from your Fiat Wallet. Process may take up to 24 hours.",
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
                          "Saved Accounts",
                          style: GoogleFonts.raleway(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // LIST BANK
                        ...List.generate(_withdrawMethods.length, (index) {
                          final method = _withdrawMethods[index];
                          final isSelected = _selectedMethodIndex == index;
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
                                  Container(
                                    width: 45, height: 45,
                                    decoration: BoxDecoration(
                                      color: Color(colorVal),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        method["code"]!,
                                        style: GoogleFonts.inter(
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
                                          style: GoogleFonts.raleway(
                                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          method["number"]!,
                                          style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
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

          // BUTTON DI BAWAH
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
                  final selectedBank = _withdrawMethods[_selectedMethodIndex];

                  // --- PERBAIKAN NAVIGASI DI SINI ---
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WithdrawAmountPage(
                        bankName: selectedBank["bank"]!,
                        accountNumber: selectedBank["number"]!,
                        // Pastikan key "name" ada di Map _withdrawMethods di atas
                        accountName: selectedBank["name"]!,
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