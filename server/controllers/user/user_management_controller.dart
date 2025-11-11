import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/employee.dart'; 

Future<Response> getAllUsersHandler(RequestContext context) async {
  try {
    final db = await Connection.getConnection();
    final dao = EmployeeDAO(db);
    final users = await dao.getAllUsers();
    
    // Mapeia os objetos do DAO para um JSON
    final jsonData = users.map((user) => {
      'id': user.id,
      'nome': user.nome,   
      'email': user.email,
      'cargo': user.cargo,  
    }).toList();

    return Response.json(body: {
      'success': true,
      'data': jsonData,
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'success': false, 'message': 'Erro ao buscar usuários: $e'},
    );
  }
}