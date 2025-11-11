import 'package:dart_frog/dart_frog.dart';
import '../../controllers/inventory/distribution_controller.dart';

Future<Response> onRequest(RequestContext context) async{
  if (context.request.method == HttpMethod.get) {
    return distributionHandler(context);
  }
  return Response(statusCode: 405, body: 'Método não permitido');
}