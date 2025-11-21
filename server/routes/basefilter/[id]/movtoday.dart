import 'package:dart_frog/dart_frog.dart';
import '../../../controllers/basefilter/mov_today_controller.dart';

Future<Response> onRequest(RequestContext context, String id) async{
  if (context.request.method == HttpMethod.get) {
    return movTodayBaseHandler(context, id);
  }
  return Response(statusCode: 405, body: 'Método não permitido');

}