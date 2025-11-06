import 'package:dart_frog/dart_frog.dart';
import '../../controllers/movimentations/five_used_controller.dart';

Future<Response> onRequest(RequestContext context) async{
  if(context.request.method == HttpMethod.get){
    return fiveUsedHandler(context);
  }
  return Response(statusCode: 405, body: 'Método não permitido');
}

