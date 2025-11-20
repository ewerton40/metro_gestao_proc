import 'package:flutter/material.dart';
import 'package:metro_projeto/providers/user_provider.dart';
import 'package:metro_projeto/screens/dashBoardScreen.dart';
import 'package:metro_projeto/screens/loginscreen.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../utils/models/notification.dart';

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

  /// controla se está no modo expandido
  bool _showAll = false;

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
    final userProvider = Provider.of<UserProvider>(context, listen: true);
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DashboardScreen(),
            ),
          );
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
        _buildNotificationButton(),
        const SizedBox(width: 8),
        _buildUserMenu(context, firstName),
        const SizedBox(width: 16),
      ],
    );
  }

  // -----------------------------
  // NOTIFICAÇÕES COM LIMITE
  // -----------------------------
  Widget _buildNotificationButton() {
    return PopupMenuButton<int>(
      onOpened: () {
        setState(() {
          _showAll = false; // reset para modo padrão MODO A
        });
        _onOpenNotifications();
      },
      offset: const Offset(0, 55),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tooltip: "Notificações",
      position: PopupMenuPosition.under,
      icon: Badge(
        label: Text(_unreadCount.toString()),
        isLabelVisible: _unreadCount > 0,
        backgroundColor: Colors.red,
        child: Icon(
          Icons.notifications_outlined,
          color: Colors.black.withOpacity(0.75),
          size: 26,
        ),
      ),
      itemBuilder: (context) {
        List<PopupMenuEntry<int>> items = [];

        // Título
        items.add(
          const PopupMenuItem(
            enabled: false,
            child: Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                "Notificações",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );

        items.add(const PopupMenuDivider());

        // Lista principal
        final listToShow =
            _showAll ? _notifications : _notifications.take(5).toList();

        if (_notifications.isEmpty) {
          items.add(
            const PopupMenuItem(
              enabled: false,
              child: Text("Nenhuma notificação disponível"),
            ),
          );
        } else {
          for (var notif in listToShow) {
            items.add(
              PopupMenuItem(
                enabled: false,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    notif.lida
                        ? Icons.mark_email_read_outlined
                        : Icons.mark_email_unread_outlined,
                    color: notif.lida ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    notif.mensagem,
                    style: TextStyle(
                      fontWeight:
                          notif.lida ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notif.data),
                ),
              ),
            );
          }
        }

        // Botão "Ver todas"
        if (!_showAll && _notifications.length > 5) {
          items.add(
            PopupMenuItem(
              value: 999,
              child: Center(
                child: Text(
                  "Ver todas",
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }

        return items;
      },
      onSelected: (value) {
        if (value == 999) {
          // Expandir temporariamente
          Navigator.pop(context); // Fecha popup

          Future.delayed(const Duration(milliseconds: 30), () {
            setState(() {
              _showAll = true;
            });

            // Reabre popup com tudo
            dynamic state = context.findRenderObject();
            if (state != null) {
              // Força reabrir
              dynamic overlay = Overlay.of(context).context.findRenderObject();
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(1000, kToolbarHeight, 0, 0),
                items: _buildExpandedNotificationItems(),
              );
            }
          });
        }
      },
    );
  }

  List<PopupMenuEntry<int>> _buildExpandedNotificationItems() {
    List<PopupMenuEntry<int>> items = [];

    items.add(
      const PopupMenuItem(
        enabled: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            "Todas as Notificações",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    items.add(const PopupMenuDivider());

    for (var notif in _notifications) {
      items.add(
        PopupMenuItem(
          enabled: false,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              notif.lida
                  ? Icons.mark_email_read_outlined
                  : Icons.mark_email_unread_outlined,
              color: notif.lida ? Colors.grey : Colors.blue,
            ),
            title: Text(
              notif.mensagem,
              style: TextStyle(
                fontWeight: notif.lida ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Text(notif.data),
          ),
        ),
      );
    }

    return items;
  }

  // -----------------------------
  // USUÁRIO
  // -----------------------------
  Widget _buildUserMenu(BuildContext context, String firstName) {
    return PopupMenuButton<String>(
      tooltip: 'Menu do Usuário',
      offset: const Offset(0, 55),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.person_outline,
                color: Colors.black.withOpacity(0.75)),
            const SizedBox(width: 8),
            Text(
              firstName.isNotEmpty ? firstName : "Usuário",
              style: TextStyle(
                color: Colors.black.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.expand_more, color: Colors.black.withOpacity(0.6)),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: "logout",
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red[700]),
              const SizedBox(width: 10),
              Text(
                "Sair",
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
      ],
      onSelected: (value) {
        if (value == "logout") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
    );
  }
}
