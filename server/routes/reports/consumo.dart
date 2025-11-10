import 'package:dart_frog/dart_frog.dart';
import 'dart:io';
import '../../controllers/report_controller.dart'; 

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return await getConsumoHandler(context);
  }

  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: {'message': 'Método não permitido.'},
  );
}