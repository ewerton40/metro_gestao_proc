import 'package:flutter/material.dart';
import 'package:metro_projeto/screens/CadastroMaterialScreen.dart';
import 'package:metro_projeto/screens/dashBoardScreen.dart';
import 'package:metro_projeto/screens/inventoryscreen.dart';
import 'package:metro_projeto/screens/reportscreen.dart';
import 'package:metro_projeto/screens/user_management_screen.dart';

class VerticalMenu extends StatefulWidget {
  const VerticalMenu({super.key});

  @override
  State<VerticalMenu> createState() => _VerticalMenuState();
}

class _VerticalMenuState extends State<VerticalMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: const Color(0xFFF5F5F5),
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        SizedBox(
          height: 130,
          child: DrawerHeader(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.asset('assets/images/logo_metro_menu.png')),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metrô de',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'Sao Paulo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Início'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (Builder) => const DashboardScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.grid_view),
          title: const Text('Painel'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.inventory_2_outlined),
          title: const Text('Inventário'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (Builder) => const InventoryScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.input),
          title: const Text('Entradas'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (Builder) => const InventoryScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Relatórios'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (Builder) => const ReportScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Gestão de Usuários'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (Builder) => const UserManagementScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.add_box_outlined),
          title: const Text('Cadastrar Material'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (Builder) => const CadastroMaterialScreen()));
          },
        ),
      ],
    ));
  }
}
