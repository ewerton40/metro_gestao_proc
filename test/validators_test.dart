// test/utils/validators_test.dart
import 'package:flutter_test/flutter_test.dart';

// Simulamos uma classe de validação que você pode usar nas suas telas
class Validators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'E-mail é obrigatório';
    }
    if (!email.contains('@')) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (password.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }
}

void main() {
  group('Validação de E-mail', () {
    test('E-mail válido retorna null', () {
      expect(Validators.validateEmail('usuario@exemplo.com'), isNull);
    });

    test('E-mail vazio retorna erro', () {
      expect(Validators.validateEmail(''), 'E-mail é obrigatório');
    });

    test('E-mail sem @ retorna erro', () {
      expect(Validators.validateEmail('usuario.exemplo.com'), 'E-mail inválido');
    });
  });

  group('Validação de Senha', () {
    test('Senha válida retorna null', () {
      expect(Validators.validatePassword('senha123'), isNull);
    });

    test('Senha curta retorna erro', () {
      expect(Validators.validatePassword('123'), 'Senha deve ter pelo menos 6 caracteres');
    });
  });
}