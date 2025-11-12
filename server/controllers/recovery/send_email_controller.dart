import 'dart:convert';
import 'dart:math';
import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/recovery.dart';
import "../../../lib/utils/email_sender.dart";


Future<Response> sendEmailHandler(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(statusCode: 405, body: {'message': 'Método não permitido.'});
  }

  final body = await context.request.body();
  final data = jsonDecode(body);

  final email = data['email']?.toString().trim();
  if (email == null || email.isEmpty) {
    return Response.json(statusCode: 400, body: {'success': false, 'message': 'E-mail é obrigatório.'});
  }

  try {
    final conn = await Connection.getConnection();
    final dao = RecoveryDAO(conn);

    final user = await dao.getUserByEmail(email);
    if (user == null) {
      return Response.json(statusCode: 404, body: {'success': false, 'message': 'E-mail não encontrado.'});
    }

    final token = (100000 + Random().nextInt(899999)).toString();
    await dao.saveToken(email, token);

    await sendRecoveryEmail(email, token);

    return Response.json(body: {'success': true, 'message': 'Token enviado com sucesso.'});
  } catch (e) {
    print('Erro ao enviar e-mail: $e');
    return Response.json(statusCode: 500, body: {'success': false, 'message': 'Erro interno do servidor.'});
  }
}
