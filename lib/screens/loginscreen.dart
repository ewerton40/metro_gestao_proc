import 'package:flutter/material.dart';


class LoginScreen extends StatelessWidget{
  const LoginScreen({super.key});

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
              width: MediaQuery.of(context).size.width * 0.8,
            child: TextField(
            decoration: InputDecoration(
              labelText: 'Usuário:',
              labelStyle: TextStyle(color: Colors.black),
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
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
            child: TextField(
            decoration: InputDecoration(
              labelText: 'Senha:',
              labelStyle: TextStyle(color: Colors.black),
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
          )
        ],
      ),
  );

  }
}