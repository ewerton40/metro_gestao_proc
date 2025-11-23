import 'package:flutter/material.dart';
import 'package:metro_projeto/providers/user_provider.dart';
import 'package:metro_projeto/screens/dashboard_screen.dart';
import 'package:metro_projeto/screens/item_registration_screen.dart';
import 'package:metro_projeto/screens/forgot_password_screen.dart';
import 'package:metro_projeto/screens/charts_per_base_screen.dart';
import 'package:metro_projeto/screens/inventory_screen.dart';
import 'package:metro_projeto/screens/material_registration_screen.dart';
import 'package:metro_projeto/screens/login_screen.dart';
import 'package:metro_projeto/screens/movimentation_screen.dart';
import 'package:metro_projeto/screens/report_screen.dart';
import 'package:metro_projeto/screens/reset_password_screen.dart';
import 'package:metro_projeto/screens/user_management_screen.dart';
import 'package:metro_projeto/screens/user_registration_screen.dart';
import 'package:metro_projeto/screens/detail_item_screen.dart';
import 'package:metro_projeto/screens/report_screen.dart';
import 'package:metro_projeto/screens/detail_item_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'services/auth_services.dart';

void main() {
  runApp(
    MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => AuthServices()),
      ],
      
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
      home: const UserManagementScreen(),
    );
  }
}
