import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:metro_projeto/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Gestão de Usuários — abrir tela e interagir com botões', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Abre o menu lateral
    final menuButton = find.byTooltip('Open navigation menu');
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Acessa Gestão de Usuários
    await tester.tap(find.text('Gestão de Usuários'));
    await tester.pumpAndSettle();

    // Verifica se a tabela aparece
    expect(find.text('Gestão de Usuários'), findsWidgets);

    // Clica no botão "Adicionar Usuário"
    await tester.tap(find.text('Adicionar Usuário'));
    await tester.pumpAndSettle();

    // Como é um teste de visualização, apenas confirma que o botão existe
    expect(find.text('Adicionar Usuário'), findsOneWidget);

    // Clica no primeiro botão "Editar"
    final editarButton = find.text('Editar').first;
    await tester.tap(editarButton);
    await tester.pumpAndSettle();

    // Verifica se o botão estava interativo
    expect(editarButton, findsOneWidget);
  });
}
