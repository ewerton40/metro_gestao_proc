import 'package:dart_frog/dart_frog.dart';
import '../../../controllers/basefilter/critical_itens_controller.dart';


Future<Response> onRequest(RequestContext context, String id) async{
  if (context.request.method == HttpMethod.get) {
    return criticalItensBaseHandler(context, id);
  }
  return Response(statusCode: 405, body: 'Método não permitido');

}
