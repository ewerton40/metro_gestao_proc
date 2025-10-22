import 'package:flutter/material.dart';
import 'package:metro_projeto/db/connection.dart';
import 'package:metro_projeto/screens/ItemRegistrationScreen.dart';
import 'package:metro_projeto/screens/inventoryscreen.dart';
import 'package:metro_projeto/screens/CadastroMaterialScreen.dart';
import 'package:metro_projeto/screens/loginscreen.dart';
import 'package:metro_projeto/screens/reportscreen.dart';
import 'package:metro_projeto/screens/usermanagementscreen.dart';
import 'package:metro_projeto/screens/detalhe_item_screen.dart';
import 'package:metro_projeto/screens/loginscreen.dart';
import 'package:metro_projeto/screens/reportscreen.dart';
import 'package:metro_projeto/screens/usermanagementscreen.dart';
import 'package:metro_projeto/screens/detalhe_item_screen.dart';

void main() {
  runApp(const MyApp());
  final db = Connection();
  db.connect();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ReportScreen(),
    );
  }
}
