import 'package:dart_frog/dart_frog.dart';
import '../../controllers/recovery/reset_password_controller.dart';

Future<Response> onRequest(RequestContext context) async{
  if (context.request.method == HttpMethod.post) {
    return resetPasswordHandler(context);
  }
  return Response(statusCode: 405, body: 'Método não permitido');

}