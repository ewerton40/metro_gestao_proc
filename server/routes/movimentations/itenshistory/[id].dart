import 'package:dart_frog/dart_frog.dart';
import '../../../controllers/inventory/itens_details_controller.dart';
import '../../../controllers/movimentations/itens_history_controller.dart';


Future<Response> onRequest(RequestContext context, String id) async{
  if (context.request.method == HttpMethod.get) {
    return itensHistoryHandler(context, id);
  }
  return Response(statusCode: 405, body: 'Método não permitido');
}