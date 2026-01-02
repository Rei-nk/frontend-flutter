import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = "Loading...";
  String _userIdStr = "...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "Sultan Kripto";
      final id = prefs.getInt('userId') ?? 0;
      _userIdStr = "User$id";
    });
  }

  // --- FUNGSI LOGOUT YANG SUDAH DIPERBAIKI ---
  Future<void> _handleLogout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        title: Text("Log Out", style: GoogleFonts.raleway(color: Colors.white)),
        content: Text("Apakah Anda yakin ingin keluar akun?", style: GoogleFonts.raleway(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Log Out", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        // PERHATIKAN BAGIAN INI:
        Navigator.pushAndRemoveUntil(
          context,
          // Ganti 'MyApp' dengan nama Class yang ada di dalam main.dart kamu.
          // Bisa jadi 'MyApp', 'LoginPage', atau 'MainPage'.
          // Pastikan huruf besarnya sesuai.
          MaterialPageRoute(builder: (context) => const MyApp()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(color: Colors.black),
          Positioned.fill(
            child: Image.asset(
              'assets/subbg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.3),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 10),
                      Text("Account Settings", style: GoogleFonts.raleway(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.purpleAccent, width: 2),
                          gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF7B1FA2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 50),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.green)),
                            child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 12), const SizedBox(width: 4), Text("Verified", style: GoogleFonts.inter(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))]),
                          ),
                          const SizedBox(height: 8),
                          Text("WELCOME", style: GoogleFonts.raleway(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(_userName, style: GoogleFonts.raleway(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(_userIdStr, style: GoogleFonts.inter(color: Colors.cyanAccent, fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildMenuItem(Icons.person_outline, "Personal Settings", () {}),
                      _buildMenuItem(Icons.lock_outline, "Account Security", () {}),
                      _buildMenuItem(Icons.info_outline, "About CRYPTOPAY", () {}),
                      const SizedBox(height: 20),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 20),
                      _buildMenuItem(Icons.logout, "Log Out", _handleLogout, isDanger: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
        child: Row(
          children: [
            Icon(icon, color: isDanger ? Colors.redAccent : Colors.white, size: 28),
            const SizedBox(width: 20),
            Expanded(child: Text(title, style: GoogleFonts.raleway(color: isDanger ? Colors.redAccent : Colors.white, fontSize: 18, fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}