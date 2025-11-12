import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/admnistrator.dart'; 

Future<Response> updateUserHandler(RequestContext context, String id) async {
  
  final body = await context.request.json() as Map<String, dynamic>;
  final String nome = body['nome'] as String;
  final String email = body['email'] as String;
  final String cargo = body['cargo'] as String;
  
  final String? senha = body['senha'] as String?; 
  
  try {
    final db = await Connection.getConnection();
    final dao = AdmnistratorDAO(db);
    
    final success = await dao.updateUser(
      id: int.parse(id), 
      nome: nome,
      email: email,
      cargo: cargo,
      senha: senha,
    );
    
    return Response.json(body: {
      'success': success,
      'message': 'Usuário atualizado com sucesso!',
    });

  } catch (e) {
    return Response.json(
      statusCode: 400, // Bad Request
      body: {'success': false, 'message': '$e'},
    );
  }
}