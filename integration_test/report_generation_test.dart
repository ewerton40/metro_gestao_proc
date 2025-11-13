import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:metro_projeto/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Relatórios — aplicar filtros e gerar PDF', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Abre o menu e acessa Relatórios
    final menuButton = find.byTooltip('Open navigation menu');
    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Relatórios'));
    await tester.pumpAndSettle();

    // Seleciona filtros
    await tester.tap(find.text('Categoria'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todas').last);
    await tester.pumpAndSettle();

    // Gera o relatório de "Movimentações"
    await tester.tap(find.text('Gerar').first);
    await tester.pumpAndSettle();

    expect(find.text('Relatórios'), findsOneWidget);
  });
}
