import 'package:flutter/material.dart';
import 'package:metro_projeto/providers/user_provider.dart';
import 'package:metro_projeto/screens/dashBoardScreen.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';
 

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

    final success = await _notificationService.markAllAsRead();

    if (success && mounted) {
      setState(() {
        _unreadCount = 0;
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
      backgroundColor: Colors.white,
      elevation: 0, 
      surfaceTintColor: Colors.transparent, 
      shape: Border(
        bottom: BorderSide(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      title: InkWell(
        onTap: () {
          Navigator.push(context, 
           MaterialPageRoute(
                builder: (Builder) => const DashboardScreen(),
            ));
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Image.asset(
          'assets/images/logo_metro_bar.png',
          height: kToolbarHeight * 0.7, 
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        _buildNotificationMenu(),
        
        const SizedBox(width: 8),

        _buildUserMenu(context, firstName),

        const SizedBox(width: 16),
      ],
    );
  }


  Widget _buildNotificationMenu() {
    return PopupMenuButton<NotificationModel>(
      onOpened: _onOpenNotifications, 
      tooltip: 'Notificações',
      offset: const Offset(0, 55), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 3,

      icon: Badge(
        label: Text(_unreadCount.toString()),
        isLabelVisible: _unreadCount > 0,
        backgroundColor: Colors.redAccent, 
        child: Icon(
          Icons.notifications_outlined,
          color: Colors.black.withOpacity(0.7), 
          size: 26,
        ),
      ),


      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<NotificationModel>> items = [];

        items.add(
          const PopupMenuItem(
            enabled: false,
            child: Text(
              'Notificações',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );

        items.add(const PopupMenuDivider());

        if (_notifications.isEmpty) {
          items.add(
            const PopupMenuItem(
              enabled: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Nenhuma notificação encontrada.'),
                ),
              ),
            ),
          );
        } else {
          items.addAll(_notifications.map((notification) {
            return PopupMenuItem<NotificationModel>(
              value: notification,
              child: ListTile(
                leading: Icon(
                  notification.lida
                      ? Icons.mark_email_read_outlined
                      : Icons.mark_email_unread_outlined,
                  color: notification.lida
                      ? Colors.grey
                      : Theme.of(context).primaryColor, 
                ),
                title: Text(
                  notification.mensagem,
                  style: TextStyle(
                    fontWeight:
                        notification.lida ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(notification.data),
              ),
            );
          }));
        }
        
        return items;
      },
    );
  }


  Widget _buildUserMenu(BuildContext context, String firstName) {
    return PopupMenuButton<String>(
      tooltip: 'Menu do Usuário',
      offset: const Offset(0, 55), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              color: Colors.black.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              firstName.isNotEmpty ? firstName : 'User',
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.black.withOpacity(0.5),
            ),
          ],
        ),
      ),

      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: 'sair', 
          child: Row(
            children: [
              Icon(
                Icons.logout,
                size: 18,
                color: Colors.red[700],
              ),
              const SizedBox(width: 10),
              Text(
                'Sair',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      
      // onSelected: (String value) {
      //   if (value == 'sair') {
      //     // Ex: Provider.of<UserProvider>(context, listen: false).logout();
      //   }
      // },
    );
  }
}
