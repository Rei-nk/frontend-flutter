import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'ApiConfig.dart'; // ✅ IMPORT FILE BARU KAMU

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscure = true;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password harus diisi!"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ PANGGIL CLASS BARU: ApiConfig
      final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login');

      print("🚀 Login ke: $url");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      print("Response Status: ${response.statusCode}");

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userData = responseBody['data'];

        if (userData != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userData['id']);
          await prefs.setString('userName', userData['full_name'] ?? 'User');

          if (responseBody['token'] != null) {
            await prefs.setString('token', responseBody['token']);
          }

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Welcome back, ${userData['full_name']}!"), backgroundColor: Colors.green),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
          );
        } else {
          throw Exception("Data user null");
        }

      } else {
        if (!mounted) return;
        String errorMessage = responseBody['message'] ?? "Login Gagal";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }

    } catch (e) {
      if (!mounted) return;
      print("❌ ERROR LOGIN: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Gagal Konek. Cek ApiConfig URL & Backend."),
            backgroundColor: Colors.red
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/subbg.png', fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Container(color: const Color(0xFF050B18))),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: "Q", style: GoogleFonts.raleway(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                            TextSpan(text: "ryptoPay", style: GoogleFonts.raleway(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.undo, color: Colors.white, size: 28),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  Text(
                    "LOGIN YOUR ACCOUNT",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 40),

                  _buildCustomTextField(
                    controller: _emailController,
                    hintText: "Email",
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 20),

                  _buildCustomTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  const SizedBox(height: 15),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.raleway(color: Colors.cyanAccent, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: _isLoading ? null : _handleLogin,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purpleAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                          "Login Now",
                          style: GoogleFonts.raleway(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isObscure : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            onPressed: () => setState(() => _isObscure = !_isObscure),
          )
              : null,
        ),
      ),
    );
  }
}