import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mysql_client/mysql_client.dart';


import '../../db/connection.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final db = Connection();
  MySQLConnection? conn;

  try {
    conn = await db.connect();

    // 1. Execute a consulta para buscar os itens
    final result = await conn.execute(
      'SELECT code, name, category, status, base, lastMoved FROM inventory_items'
    );

    // 2. Transforma os resultados em uma lista de Mapas 
    final itemsList = <Map<String, dynamic>>[];
    for (final row in result.rows) {
      itemsList.add(row.assoc());
    }

    // 3. Retorna a lista como um JSON
    return Response.json(body: itemsList);

  } catch (e) {
    print('Erro ao buscar inventário: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Erro ao buscar dados do inventário.'},
    );
  } finally {
    await conn?.close();
  }
}