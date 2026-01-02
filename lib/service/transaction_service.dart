import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 👇 Pastikan path ini sesuai dengan lokasi file ApiConfig kamu
import '../ApiConfig.dart';

class TransactionService {

  // ----------------------------------------------------------
  // HELPER: Header & Token
  // ----------------------------------------------------------
  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ----------------------------------------------------------
  // HELPER: Ambil User ID (PENTING UNTUK BACKEND)
  // ----------------------------------------------------------
  Future<int> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Cek apakah tersimpan sebagai int atau string, lalu return int
    if (prefs.containsKey('user_id')) {
      int? id = prefs.getInt('user_id');
      if (id != null) return id;

      String? idStr = prefs.getString('user_id');
      return int.tryParse(idStr ?? '0') ?? 0;
    }
    return 0; // Default jika tidak ditemukan (akan error di backend)
  }

  // ==========================================================
  // 1. FITUR TOP UP
  // ==========================================================
  Future<Map<String, dynamic>> topUp({
    required double amount,
    required String method,
  }) async {
    // ✅ Menggunakan URL dari ApiConfig
    final url = Uri.parse('${ApiConfig.baseUrl}');

    try {
      final headers = await _getHeaders();
      final userId = await _getUserId();

      final body = jsonEncode({
        "userId": userId,
        "amount": amount,
        "method": method, // Nama metode (misal: BCA Virtual Account)
        "bank": method,   // Backend biasanya minta field 'bank' juga
        "account": "VIRTUAL_ACCOUNT", // Dummy account untuk TopUp
        "type": "TOPUP"
      });

      print("🔵 [TopUp] Request ke: $url");
      print("🔵 [TopUp] Body: $body");

      final response = await http.post(url, headers: headers, body: body);

      print("🔵 [TopUp] Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": "Top Up Berhasil! Silakan cek saldo."
        };
      } else {
        try {
          final respData = jsonDecode(response.body);
          return {
            "success": false,
            "message": respData['message'] ?? "Gagal Top Up (${response.statusCode})"
          };
        } catch (e) {
          return {"success": false, "message": "Server Error: ${response.statusCode}"};
        }
      }
    } catch (e) {
      print("🔴 Error: $e");
      return {"success": false, "message": "Koneksi Bermasalah: $e"};
    }
  }

  // ==========================================================
  // 2. FITUR WITHDRAW
  // ==========================================================
  Future<Map<String, dynamic>> withdraw({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    // ✅ Menggunakan URL dari ApiConfig
    final url = Uri.parse('${ApiConfig.baseUrl}');

    try {
      final headers = await _getHeaders();
      final userId = await _getUserId();

      // Body disesuaikan dengan kebutuhan Backend Withdraw
      final body = jsonEncode({
        "userId": userId,
        "amount": amount,
        "bank": bankName,         // Sesuai request backend: 'bank'
        "account": accountNumber, // Sesuai request backend: 'account'
        "type": "WITHDRAW"
      });

      print("🟠 [Withdraw] Request ke: $url");
      print("🟠 [Withdraw] Body: $body");

      final response = await http.post(url, headers: headers, body: body);

      print("🟠 [Withdraw] Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": "Withdraw Berhasil! Dana sedang diproses."
        };
      } else {
        try {
          final respData = jsonDecode(response.body);
          return {
            "success": false,
            "message": respData['message'] ?? "Gagal Withdraw (${response.statusCode})"
          };
        } catch (e) {
          return {"success": false, "message": "Server Error: ${response.statusCode}"};
        }
      }
    } catch (e) {
      print("🔴 Error: $e");
      return {"success": false, "message": "Koneksi Bermasalah: $e"};
    }
  }
}