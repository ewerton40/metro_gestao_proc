import 'package:flutter/material.dart';


class LoginScreen extends StatelessWidget{
  const LoginScreen({super.key});

  Widget build(BuildContext context){
  return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        title: const Text('Com Imagem de Fundo'),
      ),
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
             // A nova imagem que você quer colocar por cima
          Center(
            child: Image.asset(
              'assets/images/sua_nova_imagem.png',
              width: 200, // Exemplo: defina o tamanho
              height: 200,
            ),
          ),
        ],
      ),
  );

  }
}