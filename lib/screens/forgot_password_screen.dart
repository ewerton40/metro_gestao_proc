import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../services/recover_services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
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
    super.dispose();
  }

  Future<void> enviarEmailRecuperacao() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite seu e-mail para recuperação.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await RecoverServices().(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail de recuperação enviado!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamed(context, '/reset_password');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo com imagem (igual ao login)
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
          // Caixa translúcida
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
                              'Recuperar Senha',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              controller: emailController,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined,
                                    color: Colors.black.withOpacity(0.7)),
                                labelText: 'E-mail:',
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.4),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.7),
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF1763A6), width: 2.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            isLoading
                                ? const CircularProgressIndicator(
                                    color: Color(0xFF1763A6),
                                  )
                                : CustomButton(
                                    onPressed: enviarEmailRecuperacao,
                                    text: const Text(
                                      'ENVIAR',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    color: const Color(0xFF1763A6),
                                    size: const Size(150, 50),
                                  ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Voltar ao login',
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
            ),
          ),
        ],
      ),
    );
  }
}
