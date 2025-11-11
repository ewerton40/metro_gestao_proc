import 'package:dart_frog/dart_frog.dart';
import 'dart:io';
import '../../controllers/user/user_update_controller.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method == HttpMethod.put) {
    return await updateUserHandler(context, id);
  }

  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: {'message': 'Método não permitido.'},
  );
}
