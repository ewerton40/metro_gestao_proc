import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/funcionario.dart';

// esse file services servira como uma area para arquivos .dart que farão requisicoes do front-end -> back-end
class AuthServices with ChangeNotifier {
  final _baseUrl = 'http://localhost:8080';

  Funcionario? _usuarioLogado;
  Funcionario? get usuario => _usuarioLogado;
  bool get estaLogado => _usuarioLogado != null;

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
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      
      if (responseBody.containsKey('data')) { 
        _usuarioLogado = Funcionario.fromJson(responseBody['data']);
      } else {
        _usuarioLogado = Funcionario.fromJson(responseBody);
      }
      
      notifyListeners();

      return responseBody; 
    } else {
      throw Exception('Falha no login: ${response.statusCode} - ${response.body}');
    }
  }
  void logout() {
    _usuarioLogado = null;
    notifyListeners();
  }
}
