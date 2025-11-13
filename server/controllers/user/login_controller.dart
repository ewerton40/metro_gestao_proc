import 'package:dart_frog/dart_frog.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../db/connection.dart';
import '../../db/admnistrator.dart';

Future<Response> loginHandler(RequestContext context) async {
  final body = await context.request.body();
  final data = jsonDecode(body);
  final email = data['email']?.toString() ?? '';
  final senha = data['senha']?.toString() ?? '';

  final db = await Connection.getConnection();
  final query = AdmnistratorDAO(db);

  final user = await query.findUserbyEmail(email);

  if (user == null) {
    // Usuário não encontrado
    return Response.json(
      statusCode: 401,
      body: {'success': false, 'message': 'Credenciais inválidas'},
    );
  }

  // Gera o hash da senha digitada
  final bytes = utf8.encode(senha);
  final digest = sha256.convert(bytes);
  final senhaDigitadaHash = digest.toString();

  if (user.senhaHash == senhaDigitadaHash || user.senhaHash == senha) {
    return Response.json(body: {
      'success': true,
      'message': 'Login OK!',
      'data': {
        'id': user.id,
        'nome': user.nome,
        'email': email,
        'cargo': user.cargo,
      }
    });
  } else {
    // Senha errada
    return Response.json(
      statusCode: 401,
      body: {'success': false, 'message': 'Credenciais inválidas'},
    );
  }
}
