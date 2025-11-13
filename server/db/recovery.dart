import 'package:mysql_client/mysql_client.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class RecoveryDAO {
  final MySQLConnection connection;
  RecoveryDAO(this.connection);

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    const query = 'SELECT id_funcionario, nome, email FROM funcionario WHERE email = :email';;
    try {
      final result = await connection.execute(query, {'email': email});
      if (result.numOfRows == 0) return null;
      return result.rows.first.assoc();
    } catch (e) {
      print('Erro no DAO ao buscar usuário por email: $e');
      rethrow;
    }
  }

  Future<void> saveToken(String email, String token) async {
    const query = '''
    INSERT INTO recuperacao_senha (email, token, criado_em)
    VALUES (:email, :token, NOW())
    ON DUPLICATE KEY UPDATE token = :token, criado_em = NOW()
    ''';
    try {
      await connection.execute(query, {'email': email, 'token': token});
    } catch (e) {
      print('Erro no DAO ao salvar token: $e');
      rethrow;
    }
  }

  Future<bool> verifyToken(String email, String token) async {
    const query = '''
    SELECT token FROM recuperacao_senha
    WHERE email = :email AND token = :token
    AND criado_em >= NOW() - INTERVAL 15 MINUTE
    ''';
    try {
      final result = await connection.execute(query, {'email': email, 'token': token});
      return result.numOfRows > 0;
    } catch (e) {
      print('Erro no DAO ao verificar token: $e');
      rethrow;
    }
  }
  

  
  Future<bool> updatePassword(String email, String novaSenha) async {
 
  final bytes = utf8.encode(novaSenha);
  final digest = sha256.convert(bytes);
  final senhaHash = digest.toString();

  const sql = '''
    UPDATE funcionario
    SET senha = :senhaHash
    WHERE email = :email
  ''';

  try {
    final result = await connection.execute(sql, {
      'senhaHash': senhaHash,
      'email': email,
    });
    print('Senha atualizada com sucesso para $email');
    return result.affectedRows.toInt() > 0;
  } catch (e) {
    print('Erro ao atualizar senha: $e');
    rethrow;
  }
}
}

