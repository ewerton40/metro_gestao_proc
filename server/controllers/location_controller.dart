import 'package:dart_frog/dart_frog.dart';
import 'dart:io';
import '../db/connection.dart';
import '../db/inventory.dart';

// Esta função será chamada pela nossa Rota
Future<Response> getAllLocationsHandler(RequestContext context) async {
  try {
    final conexao = Connection();
    final dao = InventoryDAO(await conexao.connect());
    
    final locations = await dao.getAllLocations();
    
    return Response.json(body: {
      'success': true,
      'data': locations, // Envia a lista de locais
    });

  } catch (e) {
    print('Erro no controller getAllLocationsHandler: $e');
    return Response.json(
      statusCode: 500,
      body: {'success': false, 'message': 'Erro ao buscar locais.'},
    );
  }
}