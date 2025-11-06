import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/inventory.dart';


Future<Response> criticalItensHandler(RequestContext context) async{
  if (context.request.method == HttpMethod.get) {
    try {
      final conn = await Connection.getConnection();
      final dao = InventoryDAO(conn);
      final criticalItems = await dao.getCriticalItems();

      return Response.json(body: {
        'success': true,
        'data': criticalItems,
      });
    } catch (e) {
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

