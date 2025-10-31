import 'package:dart_frog/dart_frog.dart';
import '../db/connection.dart';
import '../../lib/db/inventory.dart';

Future<Response> inventoryAllHandler(RequestContext context) async {

  if (context.request.method == HttpMethod.get) {
    try {
      final conexao = Connection();
      final db = await conexao.connect();
      final dao = InventoryDAO(db);
      final items = await dao.getAllItems();

      final data = items.map((item) => {
            'code': item.code,
            'name': item.name,
            'category': item.category,
            'status': item.status,
            'base': item.base,
            'lastMoved': item.lastMoved,
          }).toList();

      return Response.json(body: {
        'success': true,
        'count': data.length,
        'data': data,
      });
    } catch (e) {
      print('Erro no controller: $e');

      return Response.json(
        statusCode: 500,
        body: {
          'success': false,
          'message': 'Erro interno ao buscar inventário.',
        },
      );
    }
  }
  return Response.json(
    statusCode: 405,
    body: {'message': 'Método não permitido'},
  );
}