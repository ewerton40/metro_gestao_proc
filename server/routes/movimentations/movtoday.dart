import 'package:dart_frog/dart_frog.dart';
import '../../controllers/movimentations/mov_today_controller.dart';

Future<Response> onRequest(RequestContext context) async {
  if(context.request.method == HttpMethod.get){
    return movTodayHandler(context);
  }
  return Response(statusCode: 405, body: 'Método não permitido');
}
