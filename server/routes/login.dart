import 'package:dart_frog/dart_frog.dart';
import '../controllers/login_controller.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    return loginHandler(context);
  }
  return Response(statusCode: 405, body: 'Método não permitido');
}
