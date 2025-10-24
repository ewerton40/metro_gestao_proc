import 'package:dart_frog/dart_frog.dart';
import 'dart:convert';

Future<Response> loginHandler(RequestContext context) async {
  final body = await context.request.body();
  final data = jsonDecode(body);

  final email = data['email'];
  final senha = data['senha'];

  final user = await findUserByEmail(email); 
  if (user != null && user.senha == senha) {
    return Response.json(body: {'success': true, 'message': 'Login OK!'});
  } else {
    return Response.json(
      statusCode: 401,
      body: {'success': false, 'message': 'Credenciais inválidas'},
    );
  }
}
