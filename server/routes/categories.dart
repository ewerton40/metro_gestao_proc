import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

// Esta função será chamada quando o app acessar /categories
Future<Response> onRequest(RequestContext context) async {
  
  // Por enquanto, é so um teste
  
  return Response.json(
    statusCode: HttpStatus.ok,
    body: [], 
  );
}