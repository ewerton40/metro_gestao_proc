import 'package:dart_frog/dart_frog.dart';
import 'dart:io';

Future<Response> notificationHandler(RequestContext context) async {
  
  try {
    
    if (context.request.method == HttpMethod.get) {
      // TODO: Adicionar a lógica de buscar notificações do banco
      
      return Response.json(body: {'success': true, 'data': []});
    }
    
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed, 
      body: {'success': false, 'message': 'Método não permitido. Use GET.'},
    );

  } catch (e) { 
    print('Erro no notificationHandler: $e');
    
    return Response.json(
      statusCode: 500,
      body: {'success': false, 'message': 'Erro interno do servidor.'},
    );
  }
}