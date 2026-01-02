import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ApiConfig.dart';

class WalletService {

  // Ubah return type jadi Map<String, dynamic>
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      return {'balance': 0.0, 'name': ''}; // Default kosong
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data'];

        if (userData != null) {
          // Ambil Balance
          double balance = double.tryParse(userData['balance'].toString()) ?? 0.0;

          // ✅ AMBIL NAMA JUGA (Pastikan key json backend sesuai, misal 'name' atau 'username')
          String realName = userData['name'] ?? userData['username'] ?? "Unknown User";

          return {
            'balance': balance,
            'name': realName, // Kita kembalikan nama asli user
          };
        }
      }
    } catch (e) {
      print("❌ Error: $e");
    }
    return {'balance': 0.0, 'name': ''};
  }
}