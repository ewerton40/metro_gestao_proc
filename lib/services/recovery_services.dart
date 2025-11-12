import 'dart:convert';
import 'package:http/http.dart' as http;

class RecoveryServices {

  final String baseUrl = 'http://localhost:8080'; 

  Future<Map<String, dynamic>> enviarEmailRecuperacao(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recovery/sendemail'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao enviar e-mail: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verificarToken(String email, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recovery/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'token': token}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Token inválido ou expirado.');
    }
  }

    Future<bool> resetPassword(String email, String novaSenha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recovery/resetpassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nova_senha': novaSenha, 'email': email}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['success'] == true;
    } else {
      return false;
    }
  }
}

