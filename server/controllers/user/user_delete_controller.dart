import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import '../../db/admnistrator.dart';
import '../../db/connection.dart';

Future<Response> deleteUserHandler(RequestContext context, String id) async {

  final db = await Connection.getConnection();
  final dao = AdmnistratorDAO(db);

  try {
    final deleted = await dao.deleteUser(int.parse(id));

    if (!deleted) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Usuário não encontrado.'},
      );
    }

    return Response.json(
      body: {'message': 'Usuário excluído com sucesso.'},
    );
  } catch (e) {
    print("Erro em deleteUserHandler: $e");
    return Response.json(
      statusCode: 500,
      body: {'error': e.toString()},
    );
  }
}
