import 'package:dart_frog/dart_frog.dart';

import '../controllers/inventory/category_controller.dart';


Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return categoryHandler(context);
  }
  return Response(statusCode: 405, body: 'Método não permitido');

}