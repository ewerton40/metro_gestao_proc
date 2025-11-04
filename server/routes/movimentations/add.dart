import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async{
  if(context.request.method == HttpMethod.get){
    return addMoveHandler(context);
  }
  return Response(body: 'This is a new route!');
}
