import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class RecoverServices {
  final String baseUrl = 'http://localhost:8080'; 
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String novaSenha,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'token': token,
        'newPassword': novaSenha,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Erro no resetSenha: ${response.body}');
      return false;
    }
  }
}

    Future<void> sendResetEmail(String email, String token) async {
    final smtpServer = gmail(
      const String.fromEnvironment('EMAIL_USER'),
      const String.fromEnvironment('EMAIL_PASS'),
    );

    final message = Message()
      ..from = Address(const String.fromEnvironment('EMAIL_USER'), 'Equipe do App')
      ..recipients.add(email)
      ..subject = 'Redefinição de Senha'
      ..text = '''
          Olá!

          Você solicitou uma redefinição de senha.
          Seu código de redefinição é: $token
          Ele é válido por 15 minutos.

          Se você não solicitou isso, ignore este e-mail.
          ''';

    try {
      await send(message, smtpServer);
      print('E-mail de redefinição enviado para $email');
    } catch (e) {
      print('Erro ao enviar e-mail: $e');
    }
  }


