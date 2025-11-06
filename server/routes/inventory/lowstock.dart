import 'package:dart_frog/dart_frog.dart';
import '../../controllers/inventory/low_stock_controller.dart';

Future<Response> onRequest(RequestContext context) async{
  if (context.request.method == HttpMethod.post) {
    return lowStockHandler(context);
  }
  return Response(statusCode: 405, body: 'Método não permitido');
}