

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

const Map<String, ({int min, int max})> _codeRanges = {
  'Material de consumo': (min: 10000000, max: 10999999),
  'Material de Giro': (min: 15000000, max: 15999999),
  'Material Patrimoniado': (min: 16000000, max: 16999999),
  'Ferramentas Manuais': (min: 17000000, max: 17999999),
  'Debito Direto': (min: 20000000, max: 20999999),
  'material sobressalente': (min: 21000000, max: 21999999),
};

bool _checkCodeRange(int codeNumber, String category) {
  if (_codeRanges.containsKey(category)) {
    final range = _codeRanges[category]!;
 
    return codeNumber >= range.min && codeNumber <= range.max;
  }
  return false; 
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
    final rawCode = data['code'];
    final category = data['category'] as String;

    final code = int.tryParse(rawCode.toString()); 
    
    if (code == null) {
       
        return Response.json(
            statusCode: 400,
            body: {'success': false, 'message': 'O campo "code" (codigo_material) é obrigatório e deve ser um número inteiro válido.'},
        );
    }
     if (!_checkCodeRange(code, category)) { 
        final minRange = _codeRanges[category]?.min.toString() ?? 'N/A';
        final maxRange = _codeRanges[category]?.max.toString() ?? 'N/A';

        
        
        return Response.json(
            statusCode: 400,
            body: {
                'success': false,
                'message': 'O código do item (${code}) está fora da faixa permitida para a categoria "${category}".'
                ' Faixa esperada: ${minRange} a ${maxRange}.'
            },
        );
    }
    conexao = await Connection.getConnection(); 
    final materialDAO = MaterialDAO(conexao);

    final isDuplicated = await materialDAO.checkIfCodeExists(code);
 
    if (isDuplicated) {
      return Response.json(
        statusCode: 409,
        body: {'success': false, 'message': 'O código (${code}) já foi cadastrado no sistema, insira outro codigo.'},
      );
    }
      
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