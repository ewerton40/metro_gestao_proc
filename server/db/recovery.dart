import 'package:mysql_client/mysql_client.dart';

class PasswordResetDAO {
  final MySQLConnection connection;
  PasswordResetDAO(this.connection);

 
  Future<bool> validarToken(String email, String token) async {
    const query = '''
      SELECT 1 FROM password_reset_tokens
      WHERE email = :email AND token = :token AND expiration > NOW()
      LIMIT 1
    ''';

    final result = await connection.execute(query, {'email': email, 'token': token});
    return result.numOfRows > 0;
  }


  Future<void> atualizarSenha(String email, String novaSenha) async {
    const query = '''
      UPDATE funcionario
      SET senha = :novaSenha
      WHERE email = :email
    ''';
    await connection.execute(query, {'novaSenha': novaSenha, 'email': email});
  }

  Future<void> deletarToken(String email) async {
    const query = '''
      DELETE FROM password_reset_tokens WHERE email = :email
    ''';
    await connection.execute(query, {'email': email});
  }
}