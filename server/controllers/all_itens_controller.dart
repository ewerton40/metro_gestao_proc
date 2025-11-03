import 'package:dart_frog/dart_frog.dart';
import '../db/connection.dart';
import '../db/inventory.dart'; 

Future<Response> inventoryAllHandler(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    try {
      final conexao = Connection();
      final db = await conexao.connect();
      final dao = InventoryDAO(db);
      final items = await dao.getAllItems();

      final data = items.map((item) => {
            'id': item.id,
            'nome': item.nome,
            'categoriaId': item.categoriaId,       
            'categoriaNome': item.categoria,       
            'medidaId': item.medidaId,             
            'medidaNome': item.medida,             
            'requerCalibracao': item.requerCalibracao,
            'qtdAlto': item.qtdAlto,
            'qtdBaixo': item.qtdBaixo,
            'descricao': item.descricao,
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
          'message': 'Erro interno ao buscar materiais.',
        },
      );
    }
  }

  return Response.json(
    statusCode: 405,
    body: {'message': 'Método não permitido'},
  );
}
