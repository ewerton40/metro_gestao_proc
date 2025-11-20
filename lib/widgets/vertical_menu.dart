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
    final Color selectedTileColor = primaryColor.withOpacity(0.10);
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
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              children: [
                _verticalItem(
                  context: context,
                  icon: Icons.grid_view_outlined,
                  title: "Painel",
                  index: 0,
                  currentIndex: safeIndex,
                  selectedColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                  target: const DashboardScreen(),
                ),
                _verticalItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  title: "Inventário",
                  index: 1,
                  currentIndex: safeIndex,
                  selectedColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                  target: const InventoryScreen(),
                ),
                _verticalItem(
                  context: context,
                  icon: Icons.input_outlined,
                  title: "Entradas/Saídas",
                  index: 2,
                  currentIndex: safeIndex,
                  selectedColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                  target: const MovimentacaoScreen(),
                ),
                _verticalItem(
                  context: context,
                  icon: Icons.bar_chart_outlined,
                  title: "Relatórios",
                  index: 3,
                  currentIndex: safeIndex,
                  selectedColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                  target: const ReportScreen(),
                ),
                _verticalItem(
                  context: context,
                  icon: Icons.people_outline,
                  title: "Gestão de Usuários",
                  index: 4,
                  currentIndex: safeIndex,
                  selectedColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                  target: const UserManagementsScreen(),
                ),
                _verticalItem(
                  context: context,
                  icon: Icons.add_box_outlined,
                  title: "Cadastrar Material",
                  index: 5,
                  currentIndex: safeIndex,
                  selectedColor: primaryColor,
                  selectedTileColor: selectedTileColor,
                  defaultIconColor: defaultIconColor,
                  defaultTextColor: defaultTextColor,
                  target: const CadastroMaterialScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HEADER DO MENU
  Widget _buildHeader() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
      ),
      child: DrawerHeader(
        decoration: const BoxDecoration(color: Colors.transparent),
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
    );
  }

  // ITEM MODERNO COM ANIMAÇÃO + HOVER
  Widget _verticalItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
    required int currentIndex,
    required Color selectedColor,
    required Color selectedTileColor,
    required Color defaultIconColor,
    required Color defaultTextColor,
    required Widget target,
  }) {
    final bool isSelected = currentIndex == index;

    return _HoverBuilder(
      builder: (isHovering) {
        final bool highlight = isHovering || isSelected;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: highlight ? selectedTileColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: highlight ? selectedColor : defaultIconColor,
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                title,
                style: TextStyle(
                  color: highlight ? selectedColor : defaultTextColor,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              if (!isSelected) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => target),
                );
              }
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        );
      },
    );
  }
}

// DETECTOR DE HOVER GENÉRICO
class _HoverBuilder extends StatefulWidget {
  final Widget Function(bool isHovering) builder;
  const _HoverBuilder({required this.builder});

  @override
  State<_HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<_HoverBuilder> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: widget.builder(hovering),
    );
  }
}