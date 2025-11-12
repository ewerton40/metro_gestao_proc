import 'package:flutter/material.dart';
import 'package:metro_projeto/screens/loginscreen.dart';
import 'package:metro_projeto/screens/reset_password_screen.dart';
import '../widgets/custom_button.dart';
import '../services/recovery_services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
  with SingleTickerProviderStateMixin {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final RecoveryServices recoveryServices = RecoveryServices();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool isLoading = false;
  bool _isShowingEmailForm = true;
  String? _userEmail; 

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
    super.dispose();
  }


  Future<void> _enviarEmailRecuperacao() async {
  final email = emailController.text.trim();

  if (email.isEmpty) {
    _showSnackBar('Digite seu e-mail para recuperação.', Colors.redAccent);
    return;
  }

  setState(() => isLoading = true);
  try {
    final response = await recoveryServices.enviarEmailRecuperacao(email);

    if (response['success'] == true) {
      _showSnackBar('E-mail de recuperação enviado!', Colors.green);
      setState(() {
        _isShowingEmailForm = false;
        _userEmail = email;
      });
    } else {
      _showSnackBar(response['message'] ?? 'Erro ao enviar e-mail.', Colors.redAccent);
    }
  } catch (e) {
    _showSnackBar('Erro ao enviar e-mail: $e', Colors.redAccent);
  } finally {
    setState(() => isLoading = false);
  }
}

  Future<void> _verificarToken() async {
  final token = tokenController.text.trim();

  if (token.isEmpty) {
    _showSnackBar('Digite o token recebido.', Colors.redAccent);
    return;
  }
  if (_userEmail == null) {
  _showSnackBar('E-mail não definido. Retorne e tente novamente.', Colors.redAccent);
  return;
}
  setState(() => isLoading = true);
  try {
    final response = await recoveryServices.verificarToken(_userEmail!, token);

    if (response['success'] == true) {
      _showSnackBar('Token verificado com sucesso!', Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: _userEmail)),
      );
    } else {
      _showSnackBar(response['message'] ?? 'Token inválido.', Colors.redAccent);
    }
  } catch (e) {
    _showSnackBar('Erro ao verificar token: $e', Colors.redAccent);
  } finally {
    setState(() => isLoading = false);
  }
}

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }


  Widget _buildEmailForm() {
    return Column(
      key: const ValueKey('email_form'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Recuperar Senha',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 15),
        const Text(
          'Digite seu e-mail para enviarmos um token de recuperação.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 30),
        _buildTextField(
          controller: emailController,
          labelText: 'E-mail:',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 30),
        isLoading
            ? const CircularProgressIndicator(color: Color(0xFF1763A6))
            : CustomButton(
                onPressed: _enviarEmailRecuperacao,
                text: const Text(
                  'ENVIAR',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                color: const Color(0xFF1763A6),
                size: const Size(150, 50),
              ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen())),
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
    );
  }


  Widget _buildTokenForm() {
    return Column(
      key: const ValueKey('token_form'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Verificar Token',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 15),
        Text(
          'Um token foi enviado para:\n$_userEmail',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 30),
        _buildTextField(
          controller: tokenController,
          labelText: 'Token:',
          icon: Icons.vpn_key_outlined,
        ),
        const SizedBox(height: 30),
        isLoading
            ? const CircularProgressIndicator(color: Color(0xFF1763A6))
            : CustomButton(
                onPressed: _verificarToken,
                text: const Text(
                  'CONFIRMAR',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                color: const Color(0xFF1763A6),
                size: const Size(150, 50),
              ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => setState(() => _isShowingEmailForm = true),
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
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
 
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/recuperacao_fundo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _isShowingEmailForm
                          ? _buildEmailForm()
                          : _buildTokenForm(),
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
