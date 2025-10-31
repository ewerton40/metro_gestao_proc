import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../lib/db/inventory.dart'; // ajuste o caminho conforme seu projeto
import '../db/connection.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final db = Connection();
  final conn = await db.connect();

  try {
    final inventoryDAO = InventoryDAO(conn);
    final items = await inventoryDAO.getAllItems();
    final jsonList = items.map((item) => {
      'code': item.code,
      'name': item.name,
      'category': item.category,
      'status': item.status,
      'base': item.base,
      'lastMoved': item.lastMoved,
    }).toList();

    return Response.json(body: jsonList);
  } catch (e) {
    print('Erro ao buscar inventário: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Erro ao buscar dados do inventário.'},
    );
  } finally {
    await conn.close();
  }
}
