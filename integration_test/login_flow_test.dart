import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Teste de integração básico - deve encontrar um texto', (tester) async {
    // Construa um widget mínimo para teste
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Teste Metro Gestão'),
        ),
      ),
    );

    // Verifique se o texto está presente
    expect(find.text('Teste Metro Gestão'), findsOneWidget);
  });

  testWidgets('Teste de integração - deve encontrar um botão', (tester) async {
    // Construa um widget com um botão
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {},
            child: const Text('Botão de Teste'),
          ),
        ),
      ),
    );

    // Verifique se o botão está presente
    expect(find.text('Botão de Teste'), findsOneWidget);
  });
}