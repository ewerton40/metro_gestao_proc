import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget{
  
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

  class _LoginScreenState extends State<LoginScreen>{

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
             onPressed: (){},
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