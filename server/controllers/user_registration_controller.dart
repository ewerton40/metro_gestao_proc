import 'package:dart_frog/dart_frog.dart';
import 'dart:io';
import '../db/connection.dart';
import '../db/admnistrator.dart'; 

Future<Response> registerUserHandler(RequestContext context) async {
  
  final body = await context.request.json() as Map<String, dynamic>;
  final String nome = body['nome'] as String;
  final String email = body['email'] as String;
  final String senha = body['senha'] as String;
  final String confirmarSenha = body['confirmarSenha'] as String;
  final String cargo = body['cargo'] as String;
  
  try {
    if (senha != confirmarSenha) {
      return Response.json(
        statusCode: 400, // Bad Request
        body: {'success': false, 'message': 'As senhas não conferem.'},
      );
    }
    
    final db = await Connection.getConnection();
    final dao = AdmnistratorDAO(db);
    
    final newUserId = await dao.registerNewUser(
      nome: nome,
      email: email,
      senha: senha,
      cargo: cargo,
    );
    
    return Response.json(body: {
      'success': true,
      'message': 'Usuário cadastrado com sucesso!',
      'id': newUserId,
    });

  } catch (e) {
    
    return Response.json(
      statusCode: 400, // Bad Request
      body: {'success': false, 'message': '$e'},
    );
  }
}