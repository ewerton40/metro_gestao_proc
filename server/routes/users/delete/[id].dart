import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../controllers/user/user_delete_controller.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method == HttpMethod.delete) {
    return deleteUserHandler(context, id);
  }

  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: {'message': 'Método não permitido.'},
  );
}
