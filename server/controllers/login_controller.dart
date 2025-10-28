import 'package:dart_frog/dart_frog.dart';
import 'dart:convert';
import '../db/connection.dart';
import '../../lib/db/admnistrator.dart';

Future<Response> loginHandler(RequestContext context) async {
  final body = await context.request.body();
  final data = jsonDecode(body);

  final email = data['email'];
  final senha = data['senha'];
  final conexao = Connection();
  final query = AdmnistratorDAO(await conexao.connect());
  final user = await query.findUserbyEmail(email); 
  if (user != null && senha == senha) {
    return Response.json(body: {'success': true, 'message': 'Login OK!'});
  } else {
    return Response.json(
      statusCode: 401,
      body: {'success': false, 'message': 'Credenciais inválidas'},
    );
  }
}
