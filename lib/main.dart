import 'package:flutter/material.dart';
import 'package:metro_projeto/providers/user_provider.dart';
import 'package:metro_projeto/screens/dashBoardScreen.dart';
import 'package:metro_projeto/screens/ItemRegistrationScreen.dart';
import 'package:metro_projeto/screens/inventoryscreen.dart';
import 'package:metro_projeto/screens/CadastroMaterialScreen.dart';
import 'package:metro_projeto/screens/loginscreen.dart';
import 'package:metro_projeto/screens/movimentation_screen.dart';
import 'package:metro_projeto/screens/reportscreen.dart';
import 'package:metro_projeto/screens/usermanagementscreen.dart';
import 'package:metro_projeto/screens/detalhe_item_screen.dart';
import 'package:metro_projeto/screens/loginscreen.dart';
import 'package:metro_projeto/screens/reportscreen.dart';
import 'package:metro_projeto/screens/usermanagementscreen.dart';
import 'package:metro_projeto/screens/detalhe_item_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() {
  runApp(
    MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp()
  ),
  );
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
      home: const MovimentacaoScreen(),
    );
  }
}
