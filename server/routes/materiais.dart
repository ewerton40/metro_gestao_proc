import 'package:dart_frog/dart_frog.dart';
import '../controllers/materials_controller.dart'; 

Future<Response> onRequest(RequestContext context) async {
  if(context.request.method == HttpMethod.post){
  return materialHandler(context);
  }
  return Response(body: "Erro");
}