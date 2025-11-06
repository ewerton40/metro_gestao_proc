import 'package:dart_frog/dart_frog.dart';
import '../../controllers/inventory/critical_itens_controller.dart';

Future<Response> onRequest(RequestContext context) async{
  if (context.request.method == HttpMethod.get) {
    return criticalItensHandler(context);
  }
  return Response(statusCode: 405, body: 'Método não permitido');
}
