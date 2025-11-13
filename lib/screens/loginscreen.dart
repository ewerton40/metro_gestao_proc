import 'package:flutter/material.dart';
import 'package:metro_projeto/providers/user_provider.dart';
import 'package:metro_projeto/screens/dashBoardScreen.dart';
import 'package:metro_projeto/widgets/custom_button.dart';
import '../services/auth_services.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget{
  
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

  class _LoginScreenState extends State<LoginScreen>{
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  Future<void> fazerLogin() async {
    String email = emailController.text.trim();
    String senha = senhaController.text.trim();

    try {
      AuthServices login = AuthServices();
      final response = await login.loginRequest(email, senha);
      if(response['success']){
        final nome = response['nome'];
        Provider.of<UserProvider>(context, listen: false).setFullName(nome);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
      print('Login realizado com sucesso: $response');
      }
    } catch (e) {
      print('Erro no login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no login: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context){
  return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration (
              image: DecorationImage(
                image: AssetImage('assets/images/fundo_login.png'),
              fit: BoxFit.cover,
            )
            ),
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
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
            child: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Usuário:',
              labelStyle: const TextStyle(color: Colors.black),
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 255, 255),
              border: OutlineInputBorder( 
              borderRadius: BorderRadius.circular(30)
              ),
              enabledBorder: OutlineInputBorder( 
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder( 
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(30),
              ),
              ),
           
            ),  
            ),
          ),

          Center(
            child: Padding(padding: const EdgeInsets.only(top: 120),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
            child: TextField(
            controller: senhaController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha:',
              labelStyle: const TextStyle(color: Colors.black),
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 255, 255),
              border: OutlineInputBorder( 
              borderRadius: BorderRadius.circular(30)
              ),
              enabledBorder: OutlineInputBorder( 
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder( 
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(30),
              ),
              ),
            ),
            ),
            ),
          ),
          Center(
            child: Padding(padding: const EdgeInsets.only(top: 320),
            child: CustomButton(
             onPressed: (){
              fazerLogin();
             },
             text: const Text('Entrar', 
             style: TextStyle(
              fontSize: 20,
              color: Colors.white
             )
             ),
             color: const Color(0xFF1763A6),
             size: const Size(150, 50) ,
            )
            
            ),
          )
        ],
      ),
  );
  }
  }