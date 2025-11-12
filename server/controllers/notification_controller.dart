import 'package:dart_frog/dart_frog.dart';
import '../db/connection.dart';
import '../db/notification.dart';


Future<Response> notificationHandler(RequestContext context) async {
  try {
    final db = await Connection.getConnection();
    final dao = NotificationDAO(db);
    

    final results = await Future.wait([
      dao.getNotifications(),
      dao.getUnreadCount(),
    ]);
    
    final notifications = results[0] as List<Notificacao>;
    final unreadCount = results[1] as int;

  
    final jsonData = notifications.map((n) => {
      'id': n.id,
      'mensagem': n.mensagem,
      'data': n.dataCriacao,
      'lida': n.lida,
    }).toList();

    return Response.json(body: {
      'success': true,
      'data': jsonData,
      'unreadCount': unreadCount,
    });

  } catch (e) {
    print('Erro no notificationHandler: $e');
    return Response.json(
      statusCode: 500,
      body: {'success': false, 'message': 'Erro interno do servidor.'},
    );
  }
}


Future<Response> markNotificationsAsReadHandler(RequestContext context) async {
  try {
    final db = await Connection.getConnection();
    final dao = NotificationDAO(db);
    
    final success = await dao.markAllAsRead();
    
    return Response.json(body: {
      'success': success,
      'message': 'Notificações marcadas como lidas.',
    });

  } catch (e) {
    print('Erro no markNotificationsAsReadHandler: $e');
    return Response.json(
      statusCode: 500,
      body: {'success': false, 'message': 'Erro interno do servidor.'},
    );
  }
}