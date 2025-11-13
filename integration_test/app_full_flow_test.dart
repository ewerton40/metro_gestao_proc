import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:metro_projeto/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Teste fluxo completo do app', () {
    testWidgets('Login → Dashboard → Inventário → Cadastro → Relatórios → Gestão de Usuários', (WidgetTester tester) async {
      // Iniciar o app
      app.main();
      await tester.pumpAndSettle();

      // --- LOGIN ---
      final usuarioField = find.byType(TextField).first;
      final senhaField = find.byType(TextField).last;
      final entrarButton = find.text('Entrar');

      expect(usuarioField, findsOneWidget);
      expect(senhaField, findsOneWidget);
      expect(entrarButton, findsOneWidget);

      await tester.enterText(usuarioField, 'teste_user');
      await tester.enterText(senhaField, 'senha123');
      await tester.tap(entrarButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // --- DASHBOARD ---
      expect(find.text('Movimentações Hoje'), findsOneWidget);

      // Abrir menu lateral
      final menuButton = find.byTooltip('Open navigation menu');
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // --- INVENTÁRIO ---
      await tester.tap(find.text('Inventário'));
      await tester.pumpAndSettle();
      expect(find.text('Inventário'), findsOneWidget);

      // --- CADASTRO DE ITENS ---
      await tester.tap(menuButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entradas'));  // ou onde for o acesso ao cadastro
      await tester.pumpAndSettle();
      expect(find.text('Cadastro de Itens'), findsOneWidget);

      // Preencher o formulário de cadastro de itens
      await tester.enterText(find.widgetWithText(TextFormField, 'Nome do Item'), 'Item Teste Fluxo');
      await tester.enterText(find.widgetWithText(TextFormField, 'Código do Item'), 'CODE123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Fornecedor'), 'Fornecedor XYZ');
      await tester.enterText(find.widgetWithText(TextFormField, 'Localização Física'), 'Base Central');
      await tester.enterText(find.widgetWithText(TextFormField, 'Estoque Mínimo'), '5');
      await tester.enterText(find.widgetWithText(TextFormField, 'Descrição'), 'Descrição de teste');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // --- RELATÓRIOS ---
      await tester.tap(menuButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Relatórios'));
      await tester.pumpAndSettle();
      expect(find.text('Relatórios'), findsOneWidget);
      // Pressionar um “Gerar” botão qualquer da lista
      await tester.tap(find.text('Gerar').first);
      await tester.pumpAndSettle();

      // --- GESTÃO DE USUÁRIOS ---
      await tester.tap(menuButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gestão de Usuários'));
      await tester.pumpAndSettle();
      expect(find.text('Gestão de Usuários'), findsOneWidget);
      await tester.tap(find.text('Adicionar Usuário'));
      await tester.pumpAndSettle();
      expect(find.text('Adicionar Usuário'), findsOneWidget);

      // Final de fluxo
    });
  });
}
