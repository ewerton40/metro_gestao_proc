import 'package:mysql_client/mysql_client.dart';
import 'admnistrator.dart' show LoginQueryResult;

class AllEmployeesQueryResult{
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
        final rowMap = result.rows.first.assoc();
        return LoginQueryResult(
          senhaHash: rowMap['senha'] as String,
          cargo: rowMap['cargo'] as String,
        );
      } on Exception catch (e) {
        print('Erro no DAO ao buscar credenciais: $e');
        throw Exception('Falha ao acessar o banco de dados durante o login.');
      }
    }


  // funcao 
  getAllEmployees() async{
    const String sqlQuery = ''' 
     SELECT * 
        FROM funcionario 
        WHERE cargo = 'Funcionario'
        ''';

    try {
      final result = await connection.execute(
        sqlQuery,
      );

      if (result.numOfRows == 0) {
        return null;
      }
      final rowMap = result.rows.first.assoc();
      return AllEmployeesQueryResult(
        nome: rowMap['nome'] as String,
        email: rowMap['email'] as String,
      );
    }
    on Exception catch(e){
      print("Erro ao fazer a consulta de todos os funcionarios: $e");
    }
  }
}