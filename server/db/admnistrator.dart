import 'package:mysql_client/mysql_client.dart';
import 'dart:convert'; 
import 'package:crypto/crypto.dart'; 

class LoginQueryResult {
  final String senhaHash;
  final String cargo;
  final String? nome;
  final int id;

  LoginQueryResult(
      {required this.senhaHash,
      required this.cargo,
      this.nome,
      required this.id});
}

class AdmnistratorDAO {
  final MySQLConnection connection;
  AdmnistratorDAO(this.connection);

  Future<LoginQueryResult?> findUserbyEmail(dynamic email) async {
    const String sqlQuery = '''
        SELECT id_funcionario, senha, cargo, nome 
        FROM funcionario 
        WHERE email = :email
      ''';

    try {
      final result = await connection.execute(
        sqlQuery,
        {'email': email},
      );

      if (result.numOfRows == 0) {
        return null;
      }
      final rowMap = result.rows.first.assoc();
      return LoginQueryResult(
          id: int.parse(rowMap['id_funcionario']!),
          senhaHash: rowMap['senha'] as String,
          cargo: rowMap['cargo'] as String,
          nome: rowMap['nome'] as String);
    } on Exception catch (e) {
      print('Erro no DAO ao buscar credenciais: $e');
      throw Exception('Falha ao acessar o banco de dados durante o login.');
    }
  }

  Future<int> registerNewUser({
    required String nome,
    required String email,
    required String senha,
    required String cargo,
  }) async {
    // Lógica de Hashing de Senha
    // Converte a senha (String) para bytes
    var bytes = utf8.encode(senha); 
    // Cria o hash (SHA-256)
    var digest = sha256.convert(bytes);
    // Converte o hash de volta para uma String para salvar no banco
    var senhaHash = digest.toString();

    // Checa se o usuário já existe
    final checkUser = await findUserbyEmail(email);
    if (checkUser != null) {
      throw Exception('Este e-mail já está cadastrado.');
    }

    const String sqlQuery = '''
      INSERT INTO funcionario (nome, email, senha, cargo)
      VALUES (:nome, :email, :senhaHash, :cargo)
    ''';

    try {
      final result = await connection.execute(
        sqlQuery,
        {
          'nome': nome,
          'email': email,
          'senhaHash': senhaHash,
          'cargo': cargo,
        },
      );
      return result.lastInsertID.toInt();
    } catch (e) {
      print('Erro no DAO ao registrar usuário: $e');
      rethrow;
    }
  }

  Future<bool> updateUser({
    required int id,
    required String nome,
    required String email,
    required String cargo,
    String? senha,
  }) async {
    
    // Lista de campos a serem atualizados
    List<String> setClauses = [];
    Map<String, dynamic> params = {
      'id': id,
      'nome': nome,
      'email': email,
      'cargo': cargo,
    };

    // Adiciona os campos base
    setClauses.add('nome = :nome');
    setClauses.add('email = :email');
    setClauses.add('cargo = :cargo');

    if (senha != null && senha.isNotEmpty) {
      // Se uma nova senha foi fornecida, crie o hash
      var bytes = utf8.encode(senha); 
      var digest = sha256.convert(bytes);
      var senhaHash = digest.toString();
      
      // Adiciona a senha à query
      setClauses.add('senha = :senhaHash');
      params['senhaHash'] = senhaHash;
    }
    // Se 'senha' for nula ou vazia, o campo 'senha' no banco não é tocado.

    final String sqlQuery = '''
      UPDATE funcionario 
      SET ${setClauses.join(', ')}
      WHERE id_funcionario = :id
    ''';

    try {
      final result = await connection.execute(sqlQuery, params);
      
      // Retorna 'true' se alguma linha foi de fato alterada
      return result.affectedRows > BigInt.zero;
    } catch (e) {
      print('Erro no DAO ao ATUALIZAR usuário: $e');
      rethrow;
    }
  }
}
