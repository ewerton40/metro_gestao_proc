import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../controllers/user/user_registration_controller.dart'; 

Future<Response> onRequest(RequestContext context) async {
    if (context.request.method == HttpMethod.post) {
    return await registerUserHandler(context);
  }

  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: {'message': 'Método não permitido. Use POST.'},
  );
}