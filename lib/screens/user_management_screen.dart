// Em: lib/screens/usermanagementscreen.dart
import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import 'user_registration_screen.dart';
import '../models/employee.dart'; // 
import '../services/auth_services.dart'; // 

class UserManagementsScreen extends StatefulWidget {
  const UserManagementsScreen({super.key});

  @override
  State<UserManagementsScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Funcionario> _users = []; 
  List<Funcionario> _filteredUsers = []; 
  final AuthServices _authService = AuthServices();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Busca os dados reais
    _searchController.addListener(_filterUsers);
  }

  Future<void> _fetchUsers() async {
    try {
      final usersList = await _authService.getAllUsers();
      setState(() {
        _users = usersList;
        _filteredUsers = usersList; 
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users
          .where((user) =>
              user.nome // Usa o modelo Funcionario
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              user.email // Usa o modelo Funcionario
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _showDeleteConfirmationDialog(Funcionario user) { 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar desativação'),
          content: Text('Tem certeza se quer desativar o usuário ${user.nome}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Chamar o backend para deletar (Próximo Passo)
                // setState(() {
                //   _users.remove(user);
                //   _filterUsers();
                // });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('TODO: Lógica de deletar ainda não implementada.')),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(Funcionario user) { 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserRegistrationScreen(
          usuarioParaEditar: user, // Passa o usuário para a tela de edição
        ),
      ),
    ).then((_) {
      // Recarrega a lista quando voltar da edição
      _fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarMenu(),
      drawer: const VerticalMenu(selectedIndex: 4),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestão de Usuários',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou e-mail...', // Hint atualizado
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserRegistrationScreen(),
                      ),
                    ).then((_) {
                      // Recarrega a lista quando voltar do cadastro
                      _fetchUsers();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Adicionar Usuário',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                        : Column( // Seu layout de Tabela
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(2.5),
                                    2: FlexColumnWidth(1.5),
                                    3: FlexColumnWidth(1.5),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        _buildHeaderCell('Nome'),
                                        _buildHeaderCell('E-mail'),
                                        _buildHeaderCell('Cargo'), // Era 'Role'
                                        _buildHeaderCell('Ações'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(2),
                                      1: FlexColumnWidth(2.5),
                                      2: FlexColumnWidth(1.5),
                                      3: FlexColumnWidth(1.5),
                                    },
                                    children: _filteredUsers.map((user) {
                                      return TableRow(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey[200]!,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        children: [
                                          _buildDataCell(user.nome),
                                          _buildDataCell(user.email),
                                          _buildDataCell(user.cargo),
                                          _buildActionCell(user), // Passa o objeto
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionCell(Funcionario user) { // Aceita Funcionario
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _showEditDialog(user), // Passa o 'user'
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(70, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Editar',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _showDeleteConfirmationDialog(user), // Passa o 'user'
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(70, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Excluir',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}