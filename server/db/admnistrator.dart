  import 'package:mysql_client/mysql_client.dart';

  class LoginQueryResult {
    final String senhaHash; 
    final String cargo;     
    final String? nome;
    final int id;
    
    LoginQueryResult({required this.senhaHash, required this.cargo, this.nome, required this.id});
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
          nome: rowMap['nome'] as String
        );
      } on Exception catch (e) {
        print('Erro no DAO ao buscar credenciais: $e');
        throw Exception('Falha ao acessar o banco de dados durante o login.');
      }
    }


  }