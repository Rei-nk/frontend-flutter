import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QryptoPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Mengatur font Raleway secara global
        textTheme: GoogleFonts.ralewayTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MyHomePage(), // Halaman Awal adalah Landing Page ini
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Lapisan Warna Dasar Hitam
          Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
          ),
          // Lapisan Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/subbg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.5),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Header(), // Tombol Login ada di dalam sini
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const HeroSection(),
                        const SizedBox(height: 30),
                        // Kartu Fitur 1
                        const FeatureCard(
                          icon: Icons.show_chart,
                          iconColor: Colors.blueAccent,
                          title: "TRADE",
                          description: "A trade is the voluntary act of buying and selling goods, services, or financial assets.",
                        ),
                        const SizedBox(height: 20),
                        // Kartu Fitur 2
                        const FeatureCard(
                          icon: Icons.qr_code_scanner,
                          iconColor: Colors.white,
                          title: "PAYMENT",
                          description: "This system combines various QR codes from various payment service providers.",
                        ),
                        const SizedBox(height: 20),
                        // Kartu Fitur 3
                        const FeatureCard(
                          icon: Icons.sync,
                          iconColor: Colors.greenAccent,
                          title: "CONVERT",
                          description: "Users can trade between two cryptocurrencies directly.",
                        ),
                        const SizedBox(height: 40),
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
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // LOGO di Kiri Atas
          Image.asset(
            'assets/logo.png',
            width: 140,
            height: 40,
            fit: BoxFit.contain,
          ),
          const Spacer(),

          // Tombol Log In (Gradient)
          Container(
            height: 45, // Tinggi tombol disesuaikan
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.purpleAccent],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                // --- PERBAIKAN: ARAHKAN KE LOGIN PAGE ---
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 25),
                textStyle: GoogleFonts.raleway(fontWeight: FontWeight.bold),
              ),
              child: const Text("Log In"),
            ),
          ),
        ],
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.raleway(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: Colors.white,
              shadows: [
                const Shadow(
                  blurRadius: 10.0,
                  color: Colors.cyan,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            children: const [
              TextSpan(
                text: "QRYPTOPAY",
                style: TextStyle(color: Colors.cyanAccent),
              ),
              TextSpan(
                text: ", WHERE\nDIGITAL ASSETS MEET\nREAL-WORLD\nPAYMENTS",
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "Invest, Convert, Pay, Instantly.",
          style: GoogleFonts.raleway(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.6),
                  iconColor.withOpacity(0.1)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: GoogleFonts.raleway(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              color: Colors.grey[300],
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}