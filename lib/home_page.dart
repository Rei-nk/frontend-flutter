import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'market_page.dart';
import 'wallet_page.dart';
import 'scan_page.dart';
import 'profile_page.dart';
import 'history_page.dart';
import 'withdraw_page.dart';
import 'top_up_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // --- DAFTAR HALAMAN ---
  final List<Widget> _pages = [
    const HomeContent(),    // Index 0: Home
    const MarketPage(),     // Index 1: Market
    const ScanPage(),       // Index 2: Placeholder Scan
    const HistoryPage(),    // Index 3: History
    const WalletPage(),     // Index 4: Wallet
  ];

  void _onItemTapped(int index) {
    // KHUSUS SCAN (INDEX 2): Buka page baru (Fullscreen)
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScanPage()),
      );
      return;
    }

    // SELAIN SCAN: Ganti Tab di bawah
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // BODY: Menampilkan halaman sesuai Tab yang dipilih
      body: _pages[_selectedIndex],

      // NAVIGATION BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2746).withOpacity(0.95),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, "Home", 0),
            _buildNavItem(Icons.show_chart, "Market", 1),

            // TOMBOL SCAN (TENGAH)
            GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2746),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10)
                      ],
                    ),
                    child: const Icon(Icons.qr_code_scanner,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 4),
                  Text("Scan to Pay",
                      style: GoogleFonts.raleway(
                          color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),

            _buildNavItem(Icons.history, "History", 3),
            _buildNavItem(Icons.account_balance_wallet, "Wallet", 4),
          ],
        ),
      ),
    );
  }

  // WIDGET ICON NAVBAR
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.purpleAccent : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.raleway(
              color: isSelected ? Colors.purpleAccent : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ISI KONTEN HOME
// ==================================================================
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // LAYER 1: Background Solid
        Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
        ),
        // LAYER 2: Background Image Overlay
        Positioned.fill(
          child: Image.asset(
            'assets/subbg.png',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.3),
            errorBuilder: (c, o, s) => Container(color: Colors.black),
          ),
        ),

        // LAYER 3: Scrollable Content
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER (Logo & Buttons)
                const TopHeader(),

                const SizedBox(height: 10),

                // CAROUSEL BANNER
                const PromoCarousel(),

                const SizedBox(height: 25),

                // SECTION TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Crypto, News & Education",
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        const Shadow(blurRadius: 10, color: Colors.black),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // CARD 1: EDUCATION
                const LargeInfoCard(
                  category: "Education",
                  title: "How To Buy\nBitcoin Safely",
                  desc: "To Buy Bitcoin Safely, Beginners Should Use A Reputable, Regulated Cryptocurrency Exchange.",
                ),

                const SizedBox(height: 15),

                // CARD 2: CRYPTO TODAY
                const CryptoGraphCard(
                  title: "Crypto Today",
                  price: "Rp 115.000",
                  isBitcoin: false,
                ),

                const SizedBox(height: 15),

                // CARD 3: BITCOIN TODAY
                const CryptoGraphCard(
                  title: "BITCOIN Today",
                  price: "Rp 980.000.000",
                  isBitcoin: true,
                ),

                const SizedBox(height: 15),

                // CARD 4: LEARN CRYPTO
                const LargeInfoCard(
                  category: "Education",
                  title: "LEARN CRYPTO:\nCRYPTO MADE EASY",
                  desc: "Cryptocurrency Is A Type Of Electronic Money That Operates Separately Of A Financial Institution.",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// WIDGET PENDUKUNG (HEADER, CAROUSEL, CARDS)
// ==================================================================

// --- TOP HEADER (UPDATED: Logo Image & Button Sizes) ---
class TopHeader extends StatelessWidget {
  const TopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // LOGO IMAGE
          Image.asset(
            'assets/logo.png',
            width: 100,
            height: 30,
            fit: BoxFit.contain,
            // Fallback jika logo.png belum ada/gagal load
            errorBuilder: (c, o, s) => RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "Q", style: GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: "ryptoPay", style: GoogleFonts.raleway(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
                ],
              ),
            ),
          ),

          const Spacer(),

          // TOMBOL TOPUP (SUDAH DIAKTIFKAN)
          HeaderButton(
            text: "TopUp",
            onTap: () {
              // --- 2. LOGIC NAVIGASI KE TOP UP PAGE ---
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TopUpPage())
              );
            },
          ),
          const SizedBox(width: 8),

          // TOMBOL WITHDRAW
          HeaderButton(
            text: "Withdraw",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WithdrawPage()));
            },
          ),
          const SizedBox(width: 12),

          // PROFILE ICON
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purpleAccent, width: 1.5),
              ),
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.cyanAccent, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PROMO CAROUSEL ---
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _bannerImages = [
    'assets/banner1.png',
    'assets/banner2.png',
    'assets/banner3.png',
    'assets/banner4.png',
  ];

  @override
  void initState() {
    super.initState();
    // Auto slide setiap 3 detik
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (!mounted) return;
      if (_currentPage < _bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _bannerImages.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[900],
                  image: DecorationImage(
                    image: AssetImage(_bannerImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "INVEST SMART,\nPAY SEAMLESSLY.",
          textAlign: TextAlign.center,
          style: GoogleFonts.raleway(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            shadows: [
              const Shadow(blurRadius: 15, color: Colors.purpleAccent, offset: Offset(0, 0)),
            ],
          ),
        ),
      ],
    );
  }
}

// --- TOMBOL KECIL (HEADER BUTTON) ---
class HeaderButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const HeaderButton({
    super.key,
    required this.text,
    required this.onTap
  });

  @override
  State<HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<HeaderButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.purpleAccent : Colors.transparent,
          border: Border.all(color: Colors.purpleAccent, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isPressed
              ? [BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 10)]
              : [],
        ),
        child: Text(
            widget.text,
            style: GoogleFonts.raleway(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600
            )
        ),
      ),
    );
  }
}

// --- CARD BESAR (INFO/EDUCATION) ---
class LargeInfoCard extends StatelessWidget {
  final String category;
  final String title;
  final String desc;

  const LargeInfoCard({
    super.key,
    required this.category,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: GoogleFonts.raleway(color: Colors.white70, fontSize: 12)),
              const Icon(Icons.chevron_right, color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: GoogleFonts.raleway(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(desc, style: GoogleFonts.raleway(color: Colors.grey, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}

// --- CARD GRAFIK (CRYPTO PRICE) ---
class CryptoGraphCard extends StatelessWidget {
  final String title;
  final String price;
  final bool isBitcoin;

  const CryptoGraphCard({
    super.key,
    required this.title,
    required this.price,
    required this.isBitcoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.raleway(color: Colors.white, fontSize: 14)),
              const Icon(Icons.chevron_right, color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: CustomPaint(
              painter: ChartPainter(color: isBitcoin ? Colors.greenAccent : Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(price, style: GoogleFonts.raleway(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- PAINTER GRAFIK CUSTOM ---
class ChartPainter extends CustomPainter {
  final Color color;
  ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    path.lineTo(size.width * 0.6, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(size.width, 0), 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}