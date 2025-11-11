import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../services/auth_services.dart';
import '../models/employee.dart';

class UserRegistrationScreen extends StatefulWidget {
  final Funcionario? usuarioParaEditar;
  const UserRegistrationScreen({super.key, this.usuarioParaEditar});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  // Controladores para os campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variáveis de estado para os dropdowns
  String? _selectedRole;

  // Variável para controlar a visibilidade da senha
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  final _authService = AuthServices();
  bool _isLoading = false;

  bool get _isEditing => widget.usuarioParaEditar != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final user = widget.usuarioParaEditar!;
      _nameController.text = user.nome;
      _emailController.text = user.email;
      _selectedRole = user.cargo;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const BarMenu(),
      drawer: const VerticalMenu(selectedIndex: -1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                _isEditing ? 'Editar Usuário' : 'Cadastro de Usuário',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Center(
                child: _buildFormCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o card principal do formulário
  Widget _buildFormCard() {
    return Container(
      // Limita a largura máxima do formulário para melhor legibilidade
      width: 700,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Nome Completo',
            controller: _nameController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'E-mail (Login)',
            controller: _emailController,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          // Linha para os campos de Privilégio e Status
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Privilégio',
                  value: _selectedRole,
                  items: [
                    'Administrador',
                    'Funcionario'
                  ], // Baseado na usermanagementscreen.dart
                  onChanged: (value) => setState(() => _selectedRole = value),
                  hint: 'Selecione o privilégio',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            label: 'Senha',
            controller: _passwordController,
            isObscured: _isPasswordObscured,
            onToggleVisibility: () {
              setState(() => _isPasswordObscured = !_isPasswordObscured);
            },
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            label: 'Confirmar Senha',
            controller: _confirmPasswordController,
            isObscured: _isConfirmPasswordObscured,
            onToggleVisibility: () {
              setState(() =>
                  _isConfirmPasswordObscured = !_isConfirmPasswordObscured);
            },
          ),
          const SizedBox(height: 32),
          _buildFormButtons(),
        ],
      ),
    );
  }

  /// Campo de texto padrão
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
      ],
    );
  }

  /// Campo de senha com botão de visibilidade
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscured,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
            suffixIcon: IconButton(
              icon: Icon(
                isObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[600],
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
      ],
    );
  }

  /// Campo de Dropdown
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
      ],
    );
  }

  /// Botões de ação do formulário
  Widget _buildFormButtons() {
    return Row(
      children: [
        _isLoading
            ? const CircularProgressIndicator() // Se estiver carregando, mostra o "loading"
            : ElevatedButton(
                // Chama a função _salvarUsuario
                onPressed: _salvarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1763A6),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                    _isEditing ? 'Salvar Alterações' : 'Salvar Usuário'),
              ),
        const SizedBox(width: 16),
        OutlinedButton(
          // Chama a função _limparCampos
          onPressed: _limparCampos,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey[400]!),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Future<void> _salvarUsuario() async {
    setState(() => _isLoading = true);

    try {
      if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
        throw Exception('Nome e E-mail são obrigatórios.');
      }
      if (_selectedRole == null) {
        throw Exception('Selecione um privilégio.');
      }

      final senha = _passwordController.text;
      final confirmarSenha = _confirmPasswordController.text;

      if (_isEditing) {
        if (senha.isNotEmpty && senha != confirmarSenha) {
          throw Exception('As senhas não conferem.');
        }
      } else {
        if (senha.isEmpty || confirmarSenha.isEmpty) {
          throw Exception('A senha é obrigatória.');
        }
        if (senha != confirmarSenha) {
          throw Exception('As senhas não conferem.');
        }
      }

      if (_isEditing) {
        final response = await _authService.updateUser(
          id: widget
              .usuarioParaEditar!.id, 
          nome: _nameController.text,
          email: _emailController.text,
          cargo: _selectedRole!,
          senha: senha, 
        );

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Usuário atualizado com sucesso!'),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        } else {
          throw Exception(response['message']);
        }
      } else {
        final response = await _authService.registerUser(
          nome: _nameController.text,
          email: _emailController.text,
          senha: senha,
          confirmarSenha: confirmarSenha,
          cargo: _selectedRole!,
        );

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Usuário cadastrado com sucesso! ID: ${response['id']}'),
                backgroundColor: Colors.green),
          );
          _limparCampos(); // Limpa o formulário após cadastrar
        } else {
          throw Exception(response['message']);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  // Função de limpar
  void _limparCampos() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _selectedRole = null;
    });
  }
}
