

import 'package:dart_frog/dart_frog.dart';
import 'dart:convert';
import 'package:mysql_client/mysql_client.dart';
import '../db/connection.dart';
import '../db/material.dart'; 

String _safeToString(dynamic rawValue) {
      if (rawValue is List && rawValue.isNotEmpty) {
        return rawValue.first.toString();
      }
      return rawValue?.toString() ?? '0';
    }

Future<Response> materialHandler(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405); 
  }
  
  MySQLConnection? conexao;
  
  try {
    
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

  
    
    final name = data['name'] as String;
    final code = data['code'] as String;
    if (code == null) {
  
      throw Exception('O campo "code" (codigo_material) é obrigatório e veio nulo ou faltando na requisição.');
    }


    final codeString = code as String;

    final category = data['category'] as String;
    final base = data['base'] as String;
    final supplier = data['supplier'] as String;
    final validityType = data['validityType'] as String;
    

    final rawMinStock = data['minStock'];
    final rawMaxStock = data['maxStock'];

    

    final minStockString = _safeToString(rawMinStock);
    final maxStockString = _safeToString(rawMaxStock);

    final minStock = int.tryParse(minStockString) ?? 0;
    final maxStock = int.tryParse(maxStockString) ?? 0;

    final description = data['description'] as String;
    final validityDate = data['validityDate'] as String?;

    
    conexao = await Connection.getConnection();
    
    
    final materialDAO = MaterialDAO(conexao);
    await materialDAO.saveNewMaterial(
      name: name,
      code: code,
      category: category,
      base: base,
      supplier: supplier,
      validityType: validityType,
      minStock: minStock,
      maxStock: maxStock,
      description: description,
      validityDate: validityDate,
    );

    print('SUCESSO: MATERIAL $name CADASTRADO!');
   
    return Response.json(
      statusCode: 201,
      body: {'success': true, 'message': 'Material cadastrado com sucesso!'},
    );
    
  } catch (e, stackTrace) {
    print('ERRO CRITICO NO CADASTRO DE MATERIAL');
    print('Erro ao cadastrar material: $e');
    print('STACKTRACE:');
    print(stackTrace);
    
    return Response.json(
      statusCode: 500,
      body: {'success': false, 'message': 'Falha no cadastro de material.', 'details': e.toString()},
    );
  } finally {
    
    if (conexao != null) {
      await conexao.close();
    }
  }
}