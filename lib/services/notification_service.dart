import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';



class NotificationResponse {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationResponse({
    required this.notifications,
    required this.unreadCount,
  });
}

class NotificationService {
  final String _baseUrl = 'http://localhost:8080';

  /// Busca a lista de notificações E a contagem de não lidas
  Future<NotificationResponse> fetchNotifications() async {
    final url = Uri.parse('$_baseUrl/notifications'); 
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        
        if (responseBody['success'] == true) {
          final List<dynamic> data = responseBody['data'];
          final int unreadCount = responseBody['unreadCount'];

          final notifications = data
              .map((json) => NotificationModel.fromJson(json))
              .toList();
              
          return NotificationResponse(
            notifications: notifications,
            unreadCount: unreadCount,
          );
        } else {
          throw Exception(responseBody['message']);
        }
      } else {
        throw Exception('Falha ao buscar notificações: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Avisa ao backend para marcar todas as notificações como lidas
  Future<bool> markAllAsRead() async {
    final url = Uri.parse('$_baseUrl/notifications/read');
    
    try {
      final response = await http.post(url); 
      
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}