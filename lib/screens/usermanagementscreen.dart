import 'package:flutter/material.dart';

// Um modelo de dados para representar um usuário.
class User {
  final String name;
  final String email;
  final String role;
  final String status;

  User({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // Lista de dados fictícios para popular a tabela de usuários.
  final List<User> _users = [
    User(name: 'João Silva', email: 'joao.silva...', role: 'Administrador', status: 'Ativo'),
    User(name: 'Maria Oliveira', email: 'maria.oliv...', role: 'Administrador', status: 'Ativo'),
    User(name: 'Pedro Santos', email: 'pedro.santos...', role: 'Operador', status: 'Ativo'),
    User(name: 'Ana Souza', email: 'ana.souza', role: 'Operador', status: 'Ativo'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Cor de fundo da tela
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  Expanded(child: _buildUsersTable()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Constrói a barra lateral de navegação.
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00387B), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.compare_arrows, color: Color(0xFF00387B), size: 30),
            ),
          ),
          const SizedBox(height: 20),
          _buildNavItem(Icons.dashboard_outlined, 'Dashboard'),
          _buildNavItem(Icons.inventory_2_outlined, 'Inventário'),
          _buildNavItem(Icons.bar_chart_outlined, 'Relatórios'),
          _buildNavItem(Icons.settings_outlined, 'Configurações'),
          _buildNavItem(Icons.people_outline, 'Gestão de Usuários', isSelected: true),
        ],
      ),
    );
  }

  // Widget para um item de navegação na barra lateral.
  Widget _buildNavItem(IconData icon, String title, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE9F2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFF1763A6) : Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1763A6) : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  // Constrói o cabeçalho da área de conteúdo.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gestão de Usuários',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1763A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Adicionar Usuário'),
            ),
          ],
        ),
      ],
    );
  }

  // Constrói a tabela de dados dos usuários.
  Widget _buildUsersTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        columns: const [
          DataColumn(label: Text('Nome')),
          DataColumn(label: Text('E-mail')),
          DataColumn(label: Text('Privilégios')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Ações')),
        ],
        rows: _users.map((user) {
          return DataRow(
            cells: [
              DataCell(Text(user.name)),
              DataCell(Text(user.email)),
              DataCell(Text(user.role)),
              DataCell(Text(user.status)),
              DataCell(
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1763A6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Editar'),
                    ),
                    if (user.name == 'Ana Souza') // Condição para mostrar o botão "Desativar"
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Desativar'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
