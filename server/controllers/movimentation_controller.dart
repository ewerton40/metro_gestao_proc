import 'package:dart_frog/dart_frog.dart';
import 'dart:io';
import '../db/connection.dart';
import '../db/inventory.dart';

// Esta função será chamada pela nossa Rota
Future<Response> addMovementHandler(RequestContext context) async {
  
  // 1. Ler os dados (JSON) vindos do app Flutter
  final body = await context.request.json() as Map<String, dynamic>;
  final int idMaterial = body['id_material'] as int;
  final int quantidade = body['quantidade'] as int;
  final int idLocalDestino = body['id_local_destino'] as int;
  final int idFuncionario = body['id_funcionario'] as int;
  final String observacao = body['observacao'] as String;
  
  try {
    // 2. Conectar ao banco e chamar o DAO
    final conexao = Connection();
    final dao = InventoryDAO(await conexao.connect());
    
    // 3. Chamar o método do DAO que criamos
    final newMovementId = await dao.registerMovement(
      idMaterial: idMaterial,
      quantidade: quantidade,
      idLocalDestino: idLocalDestino,
      idFuncionario: idFuncionario,
      observacao: observacao,
    );
    
    // 4. Se deu certo, retornar o JSON de sucesso
    return Response.json(body: {
      'success': true,
      'message': 'Entrada registrada com sucesso!',
      'id': newMovementId,
    });

  } catch (e) {
    // 5. Se o DAO deu erro, retornar um Erro 500
    print('Erro no controller addMovementHandler: $e');
    return Response.json(
      statusCode: 500,
      body: {
        'success': false,
        'message': 'Erro ao registrar movimentação: $e',
      },
    );
  }
}