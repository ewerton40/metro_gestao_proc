import 'package:flutter/material.dart';
import 'package:metro_projeto/screens/CadastroMaterialScreen.dart';
import 'package:metro_projeto/screens/dashBoardScreen.dart';
import 'package:metro_projeto/screens/inventoryscreen.dart';
import 'package:metro_projeto/screens/movimentation_screen.dart';
import 'package:metro_projeto/screens/reportscreen.dart';
import 'package:metro_projeto/screens/user_management_screen.dart';

class VerticalMenu extends StatelessWidget {
  

  final int selectedIndex;

  const VerticalMenu({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
   
    const Color primaryColor = Color(0xFF0D47A1); 
    final Color selectedTileColor = primaryColor.withOpacity(0.1);
    const Color defaultIconColor = Color(0xFF5F6368); 
    const Color defaultTextColor = Color(0xFF3C4043); 

   final safeIndex = (selectedIndex >= 0 && selectedIndex <= 5) ? selectedIndex : -1;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
              height: 130, 
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1.5),
                ),
              ),
              
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent, 
                ),
                
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,  
                  children: [
                    Container(
                      width: 60, 
                      height: 60,
                      padding: const EdgeInsets.all(4), 
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12), 
                      ),
                      child: Image.asset(
                        'assets/images/logo_metro_menu.png',
                        fit: BoxFit.contain,
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
                            fontWeight: FontWeight.w500, 
                            fontSize: 18, 
                            color: Colors.black54,  
                            height: 1.1, 
                          ),
                        ),
                        Text(
                          'São Paulo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 20, 
                            color: Colors.black87, 
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                  selectedColor: primaryColor,
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
                  selectedColor: primaryColor,
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
                    if (selectedIndex == 3) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (Builder) => const MovimentacaoScreen(),
                      ),
                    );
                  },
                  currentSelectedIndex: safeIndex,
                  selectedColor: primaryColor,
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
                  selectedColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                ),
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
                  selectedColor: primaryColor,
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
                        builder: (Builder) => const CadastroMaterialScreen(),
                      ),
                    );
                  },
                  currentSelectedIndex: safeIndex,
                  selectedColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                ),
          
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
    required Color selectedColor,
    required Color selectedTileColor,
    required Color defaultIconColor,
    required Color defaultTextColor,
  }) {

    final bool isSelected = currentSelectedIndex >= 0 && index == currentSelectedIndex;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? selectedColor : defaultIconColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? selectedColor : defaultTextColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap, 
      selected: isSelected,
      selectedTileColor: selectedTileColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      horizontalTitleGap: 10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}