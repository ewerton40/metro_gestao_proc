import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/recovery.dart';



Future<Response> resetPasswordHandler(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Método não permitido');
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final String? email = body['email'] as String?;
    final String? novaSenha = body['nova_senha'] as String?;

    if (email == null || novaSenha == null) {
      return Response.json(
        statusCode: 400,
        body: {'success': false, 'message': 'Email e nova senha são obrigatórios.'},
      );
    }

    final db = await Connection.getConnection();
    final dao = RecoveryDAO(db);

    final atualizado = await dao.updatePassword(email, novaSenha);

    if (atualizado) {
      return Response.json(
        body: {'success': true, 'message': 'Senha redefinida com sucesso!'},
      );
    } else {
      return Response.json(
        statusCode: 404,
        body: {'success': false, 'message': 'Usuário não encontrado.'},
      );
    }
  } catch (e) {
    print('Erro em resetpassword handler: $e');
    return Response.json(
      statusCode: 500,
      body: {'success': false, 'message': 'Erro interno no servidor.'},
    );
  }
}