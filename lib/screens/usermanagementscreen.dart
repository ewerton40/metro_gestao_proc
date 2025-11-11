import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../models/funcionario.dart'; 
import '../services/auth_services.dart'; 
import 'user_registration_screen.dart'; 

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {

  List<Funcionario> _users = [];
  final AuthServices _authService = AuthServices(); 
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final usersList = await _authService.getAllUsers();
      setState(() {
        _users = usersList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final List<Funcionario> filteredUsers;
    if (_searchText.isEmpty) {
      filteredUsers = _users; // Se a busca estiver vazia, mostra todos
    } else {
      filteredUsers = _users.where((user) {
        final nameLower = user.nome.toLowerCase();
        final emailLower = user.email.toLowerCase();
        final searchLower = _searchText.toLowerCase();
        
        return nameLower.contains(searchLower) || emailLower.contains(searchLower);
      }).toList();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const BarMenu(),
      drawer: const VerticalMenu(),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                      : _buildUsersTable(filteredUsers), 
            ),
          ],
        ),
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
        ), //
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou e-mail...',
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserRegistrationScreen()),
                ).then((_) {
                  _fetchUsers(); 
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1763A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Adicionar Usuário'),
            ), //
          ],
        ),
      ],
    );
  }
  // Constrói a tabela de dados dos usuários.
  Widget _buildUsersTable(List<Funcionario> usersToShow) { 
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ), //
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        columns: const [
          DataColumn(label: Text('Nome')),
          DataColumn(label: Text('E-mail')),
          DataColumn(label: Text('Privilégios')),
          DataColumn(label: Text('Ações')),
        ], //
        rows: usersToShow.map((user) {
          return DataRow(
            cells: [
              DataCell(Text(user.nome)),
              DataCell(Text(user.email)),
              DataCell(Text(user.cargo)),
              DataCell(
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // NAVEGA para a tela de cadastro, passando o 'user'
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserRegistrationScreen(
                              usuarioParaEditar: user, // Passa o objeto Funcionario
                            ),
                          ),
                        ).then((_) {
                          // Recarrega a lista quando voltar da edição
                          _fetchUsers();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1763A6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Editar'),
                    ), //
                    // (Lógica do botão Desativar removida para manter limpo
                    //  até implementarmos o status)
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