import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/inventory.dart';

Future<Response> itensDetailsHandler(RequestContext context, String id) async {
  if (context.request.method == HttpMethod.get) {
    try {
      final conn = await Connection.getConnection();
      final dao = InventoryDAO(conn);

      final itemId = int.tryParse(id);
      if (itemId == null) {
        return Response.json(
          statusCode: 400,
          body: {'success': false, 'error': 'ID inválido.'},
        );
      }

      final item = await dao.getItemDetail(itemId);

      if (item == null) {
        return Response.json(
          statusCode: 404,
          body: {'success': false, 'error': 'Item não encontrado.'},
        );
      }

      return Response.json(body: {'success': true, 'data': item});
    } catch (e) {
      print('Erro no handler /inventory/itensdetails: $e');
      return Response.json(
        statusCode: 500,
        body: {'success': false, 'error': e.toString()},
      );
    }
  }

  return Response.json(
    statusCode: 405,
    body: {'success': false, 'error': 'Método não permitido'},
  );
}