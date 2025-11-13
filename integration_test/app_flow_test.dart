import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:metro_projeto/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo principal do app Metro Gestão', () {
    testWidgets('Login e navegação entre telas principais', (WidgetTester tester) async {
      // Inicia o app
      app.main();
      await tester.pumpAndSettle();

      // ---------- LOGIN ----------
      final usuarioField = find.byType(TextField).first;
      final senhaField = find.byType(TextField).last;
      final entrarButton = find.text('Entrar');

      expect(usuarioField, findsOneWidget);
      expect(senhaField, findsOneWidget);
      expect(entrarButton, findsOneWidget);

      await tester.enterText(usuarioField, 'teste_user');
      await tester.enterText(senhaField, '123456');
      await tester.tap(entrarButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // ---------- DASHBOARD ----------
      expect(find.text('Dashboard'), findsWidgets);

      // Abre o menu lateral
      final menuButton = find.byTooltip('Open navigation menu');
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // ---------- INVENTÁRIO ----------
      final inventarioTile = find.text('Inventário');
      await tester.tap(inventarioTile);
      await tester.pumpAndSettle();

      expect(find.textContaining('Inventário'), findsWidgets);

      // ---------- RELATÓRIOS ----------
      await tester.tap(menuButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Relatórios'));
      await tester.pumpAndSettle();
      expect(find.text('Relatórios'), findsWidgets);

      // ---------- GESTÃO DE USUÁRIOS ----------
      await tester.tap(menuButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gestão de Usuários'));
      await tester.pumpAndSettle();
      expect(find.text('Gestão de Usuários'), findsWidgets);
    });
  });
}
