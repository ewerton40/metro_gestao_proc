import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendRecoveryEmail(String email, String token) async {
  final smtpServer = gmail('testemetroimt@gmail.com', 'ihortbbabhymdldq');

  final message = Message()
    ..from = const Address('testemetroimt@gmail.com', 'Metro Gestão')
    ..recipients.add(email)
    ..subject = 'Recuperação de Senha - Metro Gestão'
    ..text = '''
Olá!

Recebemos uma solicitação de recuperação de senha.
Seu código de verificação é: $token

Ele expira em 15 minutos.

Se você não fez essa solicitação, ignore este e-mail.
''';

  try {
    await send(message, smtpServer);
    print('E-mail enviado para $email');
  } catch (e) {
    print('Erro ao enviar e-mail: $e');
    throw Exception('Falha ao enviar e-mail.');
  }
}
