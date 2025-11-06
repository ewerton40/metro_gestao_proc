import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/inventory.dart';


Future<Response> lowStockHandler(RequestContext context) async{
  if (context.request.method == HttpMethod.get) {
    try {
      final conn = await Connection.getConnection();
      final dao = InventoryDAO(conn);
      final count = await dao.countLowStockItems();

      return Response.json(body: {'success': true, 'data': {'lowStockCount': count}});
    } catch (e) {
      return Response.json(statusCode: 500, body: {'success': false, 'error': e.toString()});
    }
  }

  return Response.json(statusCode: 405, body: {'success': false, 'error': 'Método não permitido'});
}
