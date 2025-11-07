import 'package:dart_frog/dart_frog.dart';
import '../db/connection.dart';
import '../db/inventory.dart';

Future<Response> removeMovementHandler(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final int idMaterial = body['id_material'] as int;
  final int quantidade = body['quantidade'] as int;
  final int idLocalOrigem = body['id_local_origem'] as int;
  final int idFuncionario = body['id_funcionario'] as int;
  final String observacao = body['observacao'] as String;

  try {
    final db = await Connection.getConnection();
    final dao = InventoryDAO(db);
    final newMovementId = await dao.registerSaida(
      idMaterial: idMaterial,
      quantidade: quantidade,
      idLocalOrigem: idLocalOrigem,
      idFuncionario: idFuncionario,
      observacao: observacao,
    );
    return Response.json(body: {
      'success': true,
      'message': 'Saída registrada com sucesso!',
      'id': newMovementId,
    });
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': 'Erro ao registrar saída: $e',
      },
    );
  }
}

Future<Response> addMovementHandler(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final int idMaterial = body['id_material'] as int;
  final int quantidade = body['quantidade'] as int;
  final int idLocalDestino = body['id_local_destino'] as int;
  final int idFuncionario = body['id_funcionario'] as int;
  final String observacao = body['observacao'] as String;

  try {
    final conexao = Connection.getConnection();
    final dao = InventoryDAO(await conexao);

    final newMovementId = await dao.registerMovement(
      idMaterial: idMaterial,
      quantidade: quantidade,
      idLocalDestino: idLocalDestino,
      idFuncionario: idFuncionario,
      observacao: observacao,
    );

    return Response.json(body: {
      'success': true,
      'message': 'Entrada registrada com sucesso!',
      'id': newMovementId,
    });
  } catch (e) {
    print('Erro no controller addMovementHandler: $e');
    return Response.json(
      statusCode: 500,
      body: {
        'success': false,
        'message': 'Erro ao registrar movimentação: $e',
      },
    );
  }
}
