import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../services/auth_services.dart';
import '../utils/models/employee.dart';


const Color primaryBlue = Color(0xFF001789);
const Color lightBlue = Color(0xFF42A5F5); 
const Color whiteBackground = Colors.white;
const Color inputFillColor = Color(0xFFF0F4F8); 
const Color neutralDark = Color(0xFF333333); 

class UserRegistrationScreen extends StatefulWidget {
  final Funcionario? usuarioParaEditar;
  const UserRegistrationScreen({super.key, this.usuarioParaEditar});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
 
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

 
  String? _selectedRole;

  
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
      backgroundColor: whiteBackground,
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
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue), 
              ),
              const SizedBox(height: 32), 
              Center(
                child: _buildFormCard(context), 
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o card principal do formulário
  Widget _buildFormCard(BuildContext context) {
   
    final double maxWidth = MediaQuery.of(context).size.width * 0.9 > 900
        ? 900
        : MediaQuery.of(context).size.width * 0.9;

    return Container(
      width: maxWidth, 
      padding: const EdgeInsets.all(40.0), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.15), 
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Nome Completo',
            controller: _nameController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'E-mail (Login)',
            controller: _emailController,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Privilégio',
                  value: _selectedRole,
                  items: const [
                    'Administrador',
                    'Funcionario'
                  ], 
                  onChanged: (value) => setState(() => _selectedRole = value),
                  hint: 'Selecione o privilégio',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPasswordField(
            label: 'Senha',
            controller: _passwordController,
            isObscured: _isPasswordObscured,
            onToggleVisibility: () {
              setState(() => _isPasswordObscured = !_isPasswordObscured);
            },
          ),
          const SizedBox(height: 24),
          _buildPasswordField(
            label: 'Confirmar Senha',
            controller: _confirmPasswordController,
            isObscured: _isConfirmPasswordObscured,
            onToggleVisibility: () {
              setState(() =>
                  _isConfirmPasswordObscured = !_isConfirmPasswordObscured);
            },
          ),
          const SizedBox(height: 40), 
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
                fontWeight: FontWeight.bold, color: neutralDark)), 
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: lightBlue), 
            filled: true,
            fillColor: inputFillColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none, 
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1), 
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: lightBlue, width: 2), 
            ),
          ),
        ),
      ],
    );
  }


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
                fontWeight: FontWeight.bold, color: neutralDark)), 
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscured,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: lightBlue),
            suffixIcon: IconButton(
              icon: Icon(
                isObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: lightBlue, 
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: inputFillColor, 
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none, 
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1), 
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: lightBlue, width: 2), 
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
                fontWeight: FontWeight.bold, color: neutralDark)), 
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey[600])),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: inputFillColor, 
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none, 
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1), 
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: lightBlue, width: 2), 
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildFormButtons() {
    return Row(
      children: [
        _isLoading
            ? const CircularProgressIndicator(color: primaryBlue) 
            : ElevatedButton(
              
                onPressed: _salvarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700, 
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 5, 
                ),
                child: Text(
                    _isEditing ? 'Salvar Alterações' : 'Salvar Usuário',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
        const SizedBox(width: 16),
        OutlinedButton(
       
          onPressed: _limparCampos,
          style: OutlinedButton.styleFrom(
            foregroundColor: neutralDark, 
            side: BorderSide(color: Colors.grey.shade400, width: 1), 
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
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
          _limparCampos(); 
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
