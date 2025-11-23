import 'package:flutter/material.dart';
import 'package:metro_projeto/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:metro_projeto/services/auth_services.dart';
import 'package:metro_projeto/screens/dashboard_screen.dart';
import 'package:metro_projeto/screens/login_screen.dart';
import '../services/notification_service.dart';
import '../utils/models/notification.dart';
 

const Color primaryColor = Color(0xFF1976D2); 
const Color defaultIconColor = Color(0xFF616161); 

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
    if (mounted) {
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
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final firstName = userProvider.firstName;


    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4, 
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.transparent, 
      
      
      title: InkWell(
        onTap: () {
          Navigator.push(context, 
           MaterialPageRoute(
                builder: (Builder) => const DashboardScreen(),
            ));
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Image.asset(
            'assets/images/logo_metro_bar.png',
            height: kToolbarHeight * 0.6, 
            fit: BoxFit.contain,
          ),
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
        borderRadius: BorderRadius.circular(12.0), 
      ),
      elevation: 6, 
      color: Colors.white,

      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Badge(
          label: Text(
            _unreadCount.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          isLabelVisible: _unreadCount > 0,
          backgroundColor: Colors.redAccent, 
          child: Icon(
            Icons.notifications_none_outlined, 
            color: defaultIconColor, 
            size: 24,
          ),
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
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF212121),
              ),
            ),
          ),
        );

        items.add(const PopupMenuDivider(height: 1));

        if (_notifications.isEmpty) {
          items.add(
            const PopupMenuItem(
              enabled: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Nenhuma notificação encontrada.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        } else {
          items.addAll(_notifications.map((notification) {
            return PopupMenuItem<NotificationModel>(
              value: notification,
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: notification.lida ? Colors.white : primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                child: ListTile(
                  leading: Icon(
                    notification.lida
                        ? Icons.mark_email_read_outlined
                        : Icons.mark_email_unread_outlined,
                    color: notification.lida
                        ? Colors.grey
                        : primaryColor, 
                  ),
                  title: Text(
                    notification.mensagem,
                    style: TextStyle(
                      fontWeight:
                          notification.lida ? FontWeight.w400 : FontWeight.w600,
                      fontSize: 14,
                      color: notification.lida ? Colors.grey[700] : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    notification.data,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
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
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 6,
      color: Colors.white,
      
     
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline,
              color: primaryColor, 
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              firstName.isNotEmpty ? firstName : 'Usuário',
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down, 
              color: Colors.black.withOpacity(0.5),
              size: 20,
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
                size: 20,
                color: Colors.red[600],
              ),
              const SizedBox(width: 10),
              Text(
                'Sair',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    
    onSelected: (value){
      if(value == 'sair'){
        try{
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.clearUser();

        try {
          final auth = Provider.of<AuthServices>(context, listen: false);
          auth.logout();
        } catch (_) {}

        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
        }catch(e){
          print("Erro logout: $e");
        }
      }
      else{
        print("Nao conseguiu retornar e apagar o histórico da aplicação");
      }
    }
    );
  }
}
