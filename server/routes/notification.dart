import 'package:dart_frog/dart_frog.dart';
import '../controllers/notification_controller.dart';

Response onRequest(RequestContext context) {
if (context.request.method == HttpMethod.get){
  return notificationHandler(context);
}
  return Response(body: 'This is a new route!');
}
