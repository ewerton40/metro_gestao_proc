import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:metro_projeto/providers/user_provider.dart';
import 'package:metro_projeto/screens/dashBoardScreen.dart';
import 'package:metro_projeto/widgets/custom_button.dart';
import '../services/auth_services.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

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
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> fazerLogin() async {
    String email = emailController.text.trim();
    String senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha o usuário e a senha.'),
          backgroundColor: Color.fromARGB(255, 222, 30, 30),
        ),
      );
      return;
    }

    final authService = Provider.of<AuthServices>(context, listen: false);

    try {
      await authService.loginRequest(email, senha);
      if (authService.estaLogado) {
        final nome = authService.usuario?.nome ?? 'Nome não encontrado';
        Provider.of<UserProvider>(context, listen: false).setFullName(nome);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()));
        print('Login realizado com sucesso: $nome');
      } else {
        throw Exception('Ocorreu um erro desconhecido no login.');
      }
    } catch (e) {
      print('Erro no login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no login: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/fundo_login.png'),
              fit: BoxFit.cover,
            )),
          ),
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
                            border:
                                Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: emailController,
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: Colors.black.withOpacity(0.7)),
                                  labelText: 'Usuário:',
                                  labelStyle:
                                      const TextStyle(color: Colors.black87),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 18),
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
                              TextField(
                                controller: senhaController,
                                obscureText: true,
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline,
                                      color: Colors.black.withOpacity(0.7)),
                                  labelText: 'Senha:',
                                  labelStyle:
                                      const TextStyle(color: Colors.black87),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 18),
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
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, left: 15.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      alignment: Alignment.centerLeft,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Funcionalidade "Esqueceu a Senha" ainda não implementada.')),
                                      );
                                    },
                                    child: const Text(
                                      'Esqueceu sua senha?',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              CustomButton(
                                onPressed: () {
                                  fazerLogin();
                                },
                                text: const Text(
                                  'ENTRAR',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                color: const Color(0xFF1763A6),
                                size: const Size(150, 50),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}