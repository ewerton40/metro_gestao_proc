import 'package:dart_frog/dart_frog.dart';
import '../db/connection.dart';
import '../db/inventory.dart';

Future<Response> getConsumoHandler(RequestContext context) async {
  try {
    final db = await Connection.getConnection();
    final dao = InventoryDAO(db);
    final consumo = await dao.getConsumoReport();

    return Response.json(body: {
      'success': true,
      'data': consumo,
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'success': false, 'message': 'Erro ao gerar relatório: $e'},
    );
  }
}

Future<Response> getMovimentacoesHandler(RequestContext context) async {
  try {
    final db = await Connection.getConnection();
    final dao = InventoryDAO(db);
    final movimentacoes = await dao.getMovimentacoesReport();

    return Response.json(body: {
      'success': true,
      'data': movimentacoes,
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'success': false, 'message': 'Erro ao gerar relatório: $e'},
    );
  }
}
