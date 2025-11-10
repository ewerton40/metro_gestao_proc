import 'package:dart_frog/dart_frog.dart';
import 'dart:io';
import '../../controllers/notification_controller.dart'; 

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    return await markNotificationsAsReadHandler(context);
  }
  
  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: {'message': 'Método não permitido. Use POST.'},
  );
}