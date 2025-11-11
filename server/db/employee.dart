import 'package:mysql_client/mysql_client.dart';
import 'admnistrator.dart' show LoginQueryResult;

class UserQueryResult {
  final int id;
  final String nome; // Corrigido (era name)
  final String email;
  final String cargo; // Corrigido (era role)

  UserQueryResult({
    required this.id,
    required this.nome,
    required this.email,
    required this.cargo,
  });
}

class AllEmployeesQueryResult {
  String nome;
  String email;

  AllEmployeesQueryResult({required this.nome, required this.email});
}

class EmployeeDAO {
  final MySQLConnection connection;
  EmployeeDAO(this.connection);

  Future<LoginQueryResult?> getEmployeeLoginCredentials(String email) async {
    const String sqlQuery = '''
        SELECT senha, cargo 
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
    } on Exception catch (e) {
      print('Erro no DAO ao buscar credenciais: $e');
      throw Exception('Falha ao acessar o banco de dados durante o login.');
    }
  }

  // funcao
  Future<List<UserQueryResult>> getAllUsers() async {
    const String sqlQuery = ''' 
      SELECT id_funcionario, nome, email, cargo 
      FROM funcionario
      ORDER BY nome
    '''; 

    try {
      final result = await connection.execute(sqlQuery);
      if (result.numOfRows == 0) return []; 

      // Mapeia TODOS os resultados
      return result.rows.map((row) {
        final data = row.assoc();
        return UserQueryResult(
          id: int.parse(data['id_funcionario']!),
          nome: data['nome'] ?? '',
          email: data['email'] ?? '',
          cargo: data['cargo'] ?? 'Funcionario',
        );
      }).toList();
    } catch (e) {
      print("Erro ao fazer a consulta de todos os funcionarios: $e");
      rethrow;
    }
  }
}
