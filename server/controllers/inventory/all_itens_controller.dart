import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/inventory.dart';

Future<Response> inventoryAllHandler(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    try {
      final params = context.request.uri.queryParameters;
      final baseId = params['baseId'];
      final int? baseIdInt = baseId == null ? null : int.tryParse(baseId);

      final db = await Connection.getConnection();
      final dao = InventoryDAO(db);
      
      final items = await dao.getAllItems(baseId: baseIdInt);

      final data = items.map((item) => {
            'id': item.id,
            'nome': item.nome,
            'categoriaId': item.categoriaId,       
            'categoriaNome': item.categoria,       
            'medidaId': item.medidaId,             
            'medidaNome': item.medida,             
            'requerCalibracao': item.requerCalibracao,
            'qtdAlto': item.qtdAtual,
            'qtdBaixo': item.qtdBaixo,
            'descricao': item.descricao,
            'qtdAtual': item.quantidadeAtual, 
          }).toList();

      return Response.json(body: {
        'success': true,
        'count': data.length,
        'data': data,
      });
    } catch (e) {
      print('Erro no controller inventoryAllHandler: $e');
      
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