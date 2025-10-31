import 'dart:convert';
import 'package:http/http.dart' as http;

// esse file services servira como uma area para arquivos .dart que farão requisicoes do front-end -> back-end
class AuthServices {
final _baseUrl = 'http://localhost:8080';

  Future<Map<String, dynamic>> loginRequest(String email, String senha) async {
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha no login: ${response.statusCode} - ${response.body}');
    }
  }
}

