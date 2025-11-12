import 'package:dart_frog/dart_frog.dart';
import '../../controllers/recovery/send_email_controller.dart';

Future<Response> onRequest(RequestContext context) async{
  if (context.request.method == HttpMethod.post) {
    return sendEmailHandler(context);
  }
  return Response(statusCode: 405, body: 'Método não permitido');

}
