import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../services/recover_services.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final tokenController = TextEditingController();
  final novaSenhaController = TextEditingController();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool isLoading = false;

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
    emailController.dispose();
    tokenController.dispose();
    novaSenhaController.dispose();
    super.dispose();
  }

  Future<void> redefinirSenha() async {
    final email = emailController.text.trim();
    final token = tokenController.text.trim();
    final novaSenha = novaSenhaController.text.trim();

    if (email.isEmpty || token.isEmpty || novaSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await RecoverServices().resetPassword(email: email, token: token, novaSenha: novaSenha);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha redefinida com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo igual ao login
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
              padding: const EdgeInsets.only(bottom: 400),
              child: Image.asset(
                'assets/images/logo_metro_login.png',
                width: 200,
                height: 200,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.32,
                        padding: const EdgeInsets.symmetric(
                            vertical: 50.0, horizontal: 24.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25.0),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Redefinir Senha',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              controller: emailController,
                              decoration: _inputDecoration('E-mail',
                                  Icons.email_outlined, context),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: tokenController,
                              decoration: _inputDecoration(
                                  'Código de verificação',
                                  Icons.verified_outlined,
                                  context),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: novaSenhaController,
                              obscureText: true,
                              decoration: _inputDecoration(
                                  'Nova Senha', Icons.lock_outline, context),
                            ),
                            const SizedBox(height: 30),
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
                          ],
                        ),
                      ),
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

  InputDecoration _inputDecoration(
      String label, IconData icon, BuildContext context) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.7)),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      filled: true,
      fillColor: Colors.white.withOpacity(0.4),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: Colors.white.withOpacity(0.7), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF1763A6), width: 2.0),
      ),
    );
  }
}
