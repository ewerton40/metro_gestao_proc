import 'package:dart_frog/dart_frog.dart';
import '../../db/connection.dart';
import '../../db/inventory.dart';

Future<Response> addItemHandler(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    
    final int id = body['id'] as int;
    final String nome = body['nome'] as String;
    final int categoriaId = body['categoriaId'] as int;
    final int medidaId = body['medidaId'] as int;
    final bool requerCalibracao = body['requerCalibracao'] as bool;
    final int qtdAlto = body['qtdAlto'] as int;
    final int qtdBaixo = body['qtdBaixo'] as int;
    final String descricao = body['descricao'] as String;

    final db = await Connection.getConnection();
    final dao = InventoryDAO(db);
    
    await dao.createItem(
      id: id,
      nome: nome,
      categoriaId: categoriaId,
      medidaId: medidaId,
      requerCalibracao: requerCalibracao,
      qtdAlto: qtdAlto,
      qtdBaixo: qtdBaixo,
      descricao: descricao,
    );

    return Response.json(body: {
      'success': true,
      'message': 'Item cadastrado com sucesso!',
    });

  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'success': false, 'message': 'Erro ao cadastrar: $e'},
    );
  }
}