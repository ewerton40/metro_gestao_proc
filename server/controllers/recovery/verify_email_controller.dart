import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/recovery.dart';


Future<Response> verifyHandler(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(statusCode: 405, body: {'message': 'Método não permitido.'});
  }

  final body = await context.request.body();
  final data = jsonDecode(body);

  final email = data['email']?.toString().trim();
  final token = data['token']?.toString().trim();

  if (email == null || token == null || email.isEmpty || token.isEmpty) {
    return Response.json(statusCode: 400, body: {'success': false, 'message': 'E-mail e token são obrigatórios.'});
  }

  try {
    final conn = await Connection.getConnection();
    final dao = RecoveryDAO(conn);

    final isValid = await dao.verifyToken(email, token);
    if (!isValid) {
      return Response.json(statusCode: 401, body: {'success': false, 'message': 'Token inválido ou expirado.'});
    }

    return Response.json(body: {'success': true, 'message': 'Token verificado com sucesso.'});
  } catch (e) {
    print('Erro ao verificar token: $e');
    return Response.json(statusCode: 500, body: {'success': false, 'message': 'Erro interno do servidor.'});
  }
}
