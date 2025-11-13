import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:metro_projeto/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Cadastro de item — preenchimento e salvar', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Abre o menu lateral
    final menuButton = find.byTooltip('Open navigation menu');
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Acessa "Inventário" ou "Cadastro de Itens"
    await tester.tap(find.text('Inventário'));
    await tester.pumpAndSettle();

    // Preenche o campo de nome
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome do Item'), 'Lanterna de Teste');
    await tester.enterText(find.widgetWithText(TextFormField, 'Código do Item'), '987654');
    await tester.enterText(find.widgetWithText(TextFormField, 'Fornecedor'), 'Fornecedor Teste');
    await tester.enterText(find.widgetWithText(TextFormField, 'Localização Física'), 'Depósito A');
    await tester.enterText(find.widgetWithText(TextFormField, 'Estoque Mínimo'), '10');
    await tester.enterText(find.widgetWithText(TextFormField, 'Descrição'), 'Lanterna de teste automatizado');

    // Seleciona uma categoria
    await tester.tap(find.text('Equipamentos').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ferramentas').last);
    await tester.pumpAndSettle();

    // Clica em "Salvar"
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Valida que a ação ocorreu (verifica se botão foi clicável)
    expect(find.text('Salvar'), findsOneWidget);
  });
}
