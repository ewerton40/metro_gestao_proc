import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../services/recovery_services.dart';

class ResetPasswordScreen extends StatefulWidget {
  String? email;
  ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final novaSenhaController = TextEditingController();
  final confirmNovaSenhaController = TextEditingController();
  final recoveryServices = RecoveryServices();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    novaSenhaController.dispose();
    confirmNovaSenhaController.dispose();
    super.dispose();
  }

  // Helper para mostrar SnackBar
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> redefinirSenha() async {
  final novaSenha = novaSenhaController.text.trim();
  final confirmSenha = confirmNovaSenhaController.text.trim();

  if (novaSenha.isEmpty || confirmSenha.isEmpty) {
    _showSnackBar('Preencha todos os campos.', Colors.redAccent);
    return;
  }

  if (novaSenha != confirmSenha) {
    _showSnackBar('As senhas não coincidem.', Colors.redAccent);
    return;
  }

  setState(() => isLoading = true);

  try {
    // Chama o serviço passando o email recebido da tela anterior
    final success = await recoveryServices.resetPassword(widget.email!, novaSenha);

    if (success) {
      _showSnackBar('Senha redefinida com sucesso!', Colors.green);
      // Redireciona após 1 segundo para que o usuário veja a mensagem
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context); // volta para login
      });
    } else {
      _showSnackBar('Falha ao redefinir a senha.', Colors.redAccent);
    }
  } catch (e) {
    _showSnackBar('Erro de conexão: $e', Colors.redAccent);
  } finally {
    setState(() => isLoading = false);
  }
}

  // Helper para construir os campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.7)),
        suffixIcon: suffixIcon,
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: Colors.grey.shade100,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1763A6), width: 2.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fundo com imagem
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/recuperacao_fundo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Logo
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 450),
              child: Image.asset(
                'assets/images/logo_metro_login.png',
                width: 200,
                height: 200,
              ),
            ),
          ),
          // Caixa central
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: screenSize.width * 0.35,
                    constraints: const BoxConstraints(
                      minWidth: 400,
                      maxWidth: 550,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 40.0, horizontal: 30.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Redefinir Senha',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Campo de Nova Senha
                        _buildTextField(
                          controller: novaSenhaController,
                          labelText: 'Nova Senha:',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Campo de Confirmar Senha
                        _buildTextField(
                          controller: confirmNovaSenhaController,
                          labelText: 'Confirmar Senha:',
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Botão
                        isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFF1763A6),
                              )
                            : CustomButton(
                                onPressed: redefinirSenha,
                                text: const Text(
                                  'CONFIRMAR',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                color: const Color(0xFF1763A6),
                                size: const Size(180, 50),
                              ),
                        const SizedBox(height: 20),

                        // Voltar
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Voltar',
                            style: TextStyle(
                              color: Colors.black87,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.black87,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
