import 'package:flutter/material.dart';
import 'package:metro_projeto/screens/material_registration_screen.dart';
import 'package:metro_projeto/screens/dashboard_screen.dart';
import 'package:metro_projeto/screens/inventory_screen.dart';
import 'package:metro_projeto/screens/movimentation_screen.dart';
import 'package:metro_projeto/screens/report_screen.dart';
import 'package:metro_projeto/screens/user_management_screen.dart';
import 'package:metro_projeto/providers/user_provider.dart';
import 'package:provider/provider.dart';

class VerticalMenu extends StatelessWidget {
  
  final int selectedIndex;

  const VerticalMenu({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
   
  
    const Color primaryColor = Color(0xFF1976D2); 
    const Color accentColor = Color(0xFF42A5F5); 
    const Color selectedTileColor = Color(0xFFE3F2FD); 
    const Color defaultIconColor = Color(0xFF616161);
    const Color defaultTextColor = Color(0xFF424242); 

    final safeIndex = (selectedIndex >= 0 && selectedIndex <= 5) ? selectedIndex : -1;

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 130, 
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[100]!, width: 1.0), 
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,  
                children: [
                  Container(
                    width: 60, 
                    height: 60,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_metro_menu.png',
                        fit: BoxFit.contain,
                        height: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12), 
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      Text(
                        'Metrô de',
                        style: TextStyle(
                          fontWeight: FontWeight.w400, 
                          fontSize: 16, 
                          color: defaultTextColor,  
                          height: 1.1, 
                        ),
                      ),
                      Text(
                        'São Paulo',
                        style: TextStyle(
                          fontWeight: FontWeight.w700, 
                          fontSize: 20, 
                          color: Color(0xFF212121), 
                          height: 1.2, 
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.grid_view_outlined,
                  title: 'Painel',
                  index: 0, 
                  onTap: () {
                    Navigator.pop(context);
                    if (selectedIndex == 0) return; 
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (Builder) => const DashboardScreen(),
                      ),
                    );
                  },
                  currentSelectedIndex: safeIndex,
                  primaryColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventário',
                  index: 1, 
                  onTap: () {
                    Navigator.pop(context);
                    if (selectedIndex == 1) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (Builder) => const InventoryScreen(),
                      ),
                    );
                  },
                  currentSelectedIndex: safeIndex,
                  primaryColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.input_outlined,
                  title: 'Entradas/Saídas',
                  index: 2, 
                  onTap: () {
                    Navigator.pop(context);
                    if (selectedIndex == 2) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (Builder) => const MovimentacaoScreen(),
                      ),
                    );
                  },
                  currentSelectedIndex: safeIndex,
                  primaryColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.bar_chart_outlined,
                  title: 'Relatórios',
                  index: 3, 
                  onTap: () {
                    Navigator.pop(context);
                    if (selectedIndex == 3) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (Builder) => const ReportScreen(),
                      ),
                    );
                  },
                  currentSelectedIndex: safeIndex,
                  primaryColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                ),
                Builder(builder: (context) {
                  final userProvider = Provider.of<UserProvider>(context);
                  if (userProvider.isAdmin) {
                    return Column(
                      children: [
                        _buildMenuItem(
                          context: context,
                          icon: Icons.people_outline,
                          title: 'Gestão de Usuários',
                          index: 4,
                          onTap: () {
                            Navigator.pop(context);
                            if (selectedIndex == 4) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (Builder) => const UserManagementScreen(),
                              ),
                            );
                          },
                          currentSelectedIndex: safeIndex,
                          primaryColor: primaryColor,
                          selectedTileColor: selectedTileColor,
                          defaultIconColor: defaultIconColor,
                          defaultTextColor: defaultTextColor,
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.add_box_outlined,
                          title: 'Cadastrar Material',
                          index: 5,
                          onTap: () {
                            Navigator.pop(context);
                            if (selectedIndex == 5) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (Builder) => const MaterialRegistrationScreen(),
                              ),
                            );
                          },
                          currentSelectedIndex: safeIndex,
                          primaryColor: primaryColor,
                          selectedTileColor: selectedTileColor,
                          defaultIconColor: defaultIconColor,
                          defaultTextColor: defaultTextColor,
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        // Non-admin: do not show management/register items
                      ],
                    );
                  }
                }),
          
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index, 
    required int currentSelectedIndex, 
    required VoidCallback onTap,
    required Color primaryColor,
    required Color selectedTileColor,
    required Color defaultIconColor,
    required Color defaultTextColor,
  }) {

    final bool isSelected = currentSelectedIndex >= 0 && index == currentSelectedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: isSelected ? selectedTileColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? primaryColor : defaultIconColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? primaryColor : defaultTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
