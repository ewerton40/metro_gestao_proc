import 'package:flutter/material.dart';
import 'package:metro_projeto/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

class BarMenu extends StatefulWidget implements PreferredSizeWidget {
  const BarMenu({super.key});

  @override
  State<BarMenu> createState() => _BarMenuState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BarMenuState extends State<BarMenu> {

  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await _notificationService.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = response.notifications;
          _unreadCount = response.unreadCount;
        });
      }
    } catch (e) {
      print("Erro ao buscar notificações: $e");
    }
  }

  Future<void> _onOpenNotifications() async {
    if (_unreadCount == 0) return;

    // Avisa o backend
    final success = await _notificationService.markAllAsRead();
    
    // Atualiza a UI imediatamente
    if (success && mounted) {
      setState(() {
        _unreadCount = 0;
        // Marca todas as notificações locais como lidas
        _notifications = _notifications.map((n) {
          return NotificationModel(
            id: n.id,
            mensagem: n.mensagem,
            data: n.data,
            lida: true,
          );
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final firstName = userProvider.firstName;

    return AppBar(
      title: InkWell(
        onTap: () {},
        child: Image.asset(
          'assets/images/logo_metro_bar.png',
          height: kToolbarHeight * 0.7,
          fit: BoxFit.contain,
        ),
      ),
        actions: [
        Padding(
          padding: const EdgeInsets.only(right: 50),
          child: _buildNotificationMenu(), 
        ),
        Padding(
          padding: const EdgeInsets.only(right: 50),
          child: PopupMenuButton(
              child: TextButton.icon(
                  onPressed: null,
                  icon: const Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  label: Text(firstName.isNotEmpty ? firstName : 'User',
                      style: TextStyle(color: Colors.black)),
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black)),
              offset: const Offset(50, 44),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem(
                        child: Row(children: [
                      Icon(Icons.logout, size: 15),
                      SizedBox(width: 8),
                      Text(
                        'Sair',
                        style: TextStyle(color: Colors.black),
                      ),
                    ])),
                  ]),
        ),
      ],
    );
  }

  Widget _buildNotificationMenu() {
    return PopupMenuButton<NotificationModel>(
      onOpened: _onOpenNotifications,
      
      icon: Badge(
        label: Text(_unreadCount.toString()),
        isLabelVisible: _unreadCount > 0, // Só mostra o número se for > 0
        child: const Icon(Icons.notifications_outlined, color: Colors.black54),
      ),
      
      // Constrói a lista de itens no pop-up
      itemBuilder: (BuildContext context) {
        if (_notifications.isEmpty) {
          return [
            const PopupMenuItem(
              enabled: false, 
              child: Text('Nenhuma notificação encontrada.'),
            ),
          ];
        }

        // Constrói um item para cada notificação
        return _notifications.map((notification) {
          return PopupMenuItem<NotificationModel>(
            value: notification,
            child: ListTile(
              // Ícone muda se a notificação foi lida
              leading: Icon(
                notification.lida ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                color: notification.lida ? Colors.grey : Colors.blue,
              ),
              title: Text(notification.mensagem),
              subtitle: Text(notification.data),
            ),
          );
        }).toList();
      },
    );
  }
}
