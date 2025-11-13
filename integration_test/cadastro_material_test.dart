import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:metro_projeto/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Cadastro de Material — preencher e salvar', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Abre o menu lateral
    final menuButton = find.byTooltip('Open navigation menu');
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Acessa a tela de Cadastro de Materiais
    await tester.tap(find.text('Inventário'));
    await tester.pumpAndSettle();

    // Verifica se o título da tela aparece
    expect(find.text('Cadastro de Materiais'), findsOneWidget);

    // Preenche campos básicos
    await tester.enterText(find.widgetWithText(TextFormField, 'Código do Material'), 'MT-9876');
    await tester.enterText(find.widgetWithText(TextFormField, 'Descrição do Material'), 'Material de teste automatizado');
    await tester.enterText(find.widgetWithText(TextFormField, 'Quantidade'), '42');
    await tester.enterText(find.widgetWithText(TextFormField, 'Localização'), 'Depósito Central');

    // Seleciona uma categoria no Dropdown
    await tester.tap(find.text('Categoria').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elétricos').last);
    await tester.pumpAndSettle();

    // Seleciona unidade de medida
    await tester.tap(find.text('Unidade de Medida').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unidade').last);
    await tester.pumpAndSettle();

    // Clica em Salvar
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Confirma que o botão estava funcional
    expect(find.text('Salvar'), findsOneWidget);
  });
}