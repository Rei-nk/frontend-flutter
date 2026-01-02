import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import halaman lain jika tombol header diklik (opsional)
import 'profile_page.dart';
import 'withdraw_page.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  // --- DATA DUMMY (SESUAI GAMBAR) ---
  // Nanti bisa diganti dengan data dari API
  final List<Map<String, dynamic>> topMovers = [
    {'name': 'BITCOIN', 'symbol': 'BTC', 'price': '1.837.601.761', 'change': '+2.81%', 'icon': Icons.currency_bitcoin, 'color': Colors.orange},
    {'name': 'ETH', 'symbol': 'ETH', 'price': '64.812.385', 'change': '+1.43%', 'icon': Icons.diamond_outlined, 'color': Colors.blue},
    {'name': 'SOLANA', 'symbol': 'SOL', 'price': '3.193.033', 'change': '+5.57%', 'icon': Icons.blur_on, 'color': Colors.purpleAccent},
  ];

  final List<Map<String, dynamic>> marketList = [
    {'name': 'BITCOIN', 'price': '1.837.601.761', 'change': '2,81%', 'icon': Icons.currency_bitcoin, 'color': Colors.orange},
    {'name': 'ETHEREUM', 'price': '64.812.385', 'change': '1,99%', 'icon': Icons.diamond_outlined, 'color': Colors.blue},
    {'name': 'SOLANA', 'price': '3.193.033', 'change': '5,57%', 'icon': Icons.blur_on, 'color': Colors.purpleAccent},
    {'name': 'TETHER', 'price': '15.500', 'change': '0,01%', 'icon': Icons.attach_money, 'color': Colors.teal},
    {'name': 'USD COIN', 'price': '15.490', 'change': '0,02%', 'icon': Icons.monetization_on_outlined, 'color': Colors.blueGrey},
    {'name': 'XRP', 'price': '9.200', 'change': '1,20%', 'icon': Icons.close, 'color': Colors.white},
    {'name': 'AVALANCHE', 'price': '500.000', 'change': '3,10%', 'icon': Icons.landscape, 'color': Colors.redAccent},
    {'name': 'SHIBA INU', 'price': '0.14', 'change': '5,57%', 'icon': Icons.pets, 'color': Colors.orangeAccent},
    {'name': 'DOGECOIN', 'price': '1.200', 'change': '4,20%', 'icon': Icons.incomplete_circle, 'color': Colors.yellow},
  ];

  @override
  Widget build(BuildContext context) {
    // Menggunakan Stack untuk Background Hitam + SubBG
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // LAYER 1: Solid Black
          Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
          ),

          // LAYER 2: Image Overlay (SubBG)
          Positioned.fill(
            child: Image.asset(
              'assets/subbg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.3),
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
            ),
          ),

          // LAYER 3: Konten Utama
          SafeArea(
            child: Column(
              children: [
                // 1. HEADER (Logo & Tombol)
                _buildHeader(),

                const SizedBox(height: 20),

                // 2. KONTEN SCROLLABLE
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- TITLE TOP MOVERS ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Top Movers (24H)",
                            style: GoogleFonts.raleway(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // --- LIST TOP MOVERS (HORIZONTAL) ---
                        _buildTopMoversList(),

                        const SizedBox(height: 20),

                        // GARIS PEMBATAS
                        Divider(color: Colors.white.withOpacity(0.1), thickness: 1),

                        const SizedBox(height: 20),

                        // --- SEARCH BAR ---
                        _buildSearchBar(),

                        const SizedBox(height: 10),

                        // --- MARKET LIST ---
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: marketList.length,
                          itemBuilder: (context, index) {
                            final item = marketList[index];
                            return _buildMarketItem(item);
                          },
                        ),

                        // Padding bawah supaya tidak ketutup Navbar
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: HEADER ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // LOGO KIRI
          Image.asset(
            'assets/logo.png',
            width: 100, // Sesuaikan ukuran logo kamu
            height: 30,
            fit: BoxFit.contain,
            errorBuilder: (c, o, s) => Text(
                "QryptoPay",
                style: GoogleFonts.raleway(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ),

          const Spacer(),

          // TOMBOL TOPUP (Border Ungu)
          _buildOutlineButton("TopUp", () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("TopUp Coming Soon")));
          }),

          const SizedBox(width: 8),

          // TOMBOL WITHDRAW (Border Ungu)
          _buildOutlineButton("Withdraw", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const WithdrawPage()));
          }),

          const SizedBox(width: 12),

          // TOMBOL PROFILE (Border Ungu, Lingkaran)
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

  // --- WIDGET: TOMBOL HEADER KECIL ---
  Widget _buildOutlineButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purpleAccent, width: 1.5),
        ),
        child: Text(
          text,
          style: GoogleFonts.raleway(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // --- WIDGET: TOP MOVERS LIST ---
  Widget _buildTopMoversList() {
    return SizedBox(
      height: 140, // Tinggi kartu top movers
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: topMovers.length,
        separatorBuilder: (c, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = topMovers[index];
          return Container(
            width: 130,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF121212), // Warna kartu gelap
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon & Symbol
                Row(
                  children: [
                    Icon(item['icon'], color: item['color'], size: 20),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item['name'],
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Harga (Font Inter)
                Text(
                  "Rp. ${item['price']}",
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),

                // Persentase (Font Inter)
                Text(
                  item['change'],
                  style: GoogleFonts.inter(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET: SEARCH BAR ---
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: GoogleFonts.raleway(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search your asset",
                hintStyle: GoogleFonts.raleway(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: MARKET LIST ITEM ---
  Widget _buildMarketItem(Map<String, dynamic> item) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              // Icon Kiri
              Icon(item['icon'], color: item['color'], size: 28),

              const SizedBox(width: 15),

              // Nama Aset
              Text(
                item['name'],
                style: GoogleFonts.raleway(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              // Kolom Harga & Persentase
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Harga (Inter)
                  Text(
                    "Rp. ${item['price']}",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Persentase (Inter)
                  Text(
                    "${item['change']}", // Tambahkan tanda + jika perlu
                    style: GoogleFonts.inter(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Garis Pembatas (Divider)
        Divider(
          color: Colors.white.withOpacity(0.1),
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }
}