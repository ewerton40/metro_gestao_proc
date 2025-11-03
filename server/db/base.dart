import 'package:mysql_client/mysql_client.dart';

class AllBasesQueryResult {
  final String nome;
  final String tipo;

  AllBasesQueryResult({required this.nome, required this.tipo});
}

class BaseDAO {
  final MySQLConnection connection;

  BaseDAO(this.connection);

  Future<List<AllBasesQueryResult>> getAllBases() async {
    const String sqlQuery = '''
      SELECT nome, tipo 
      FROM locais_estoque
    ''';

    try {
      final result = await connection.execute(sqlQuery);

      if (result.numOfRows == 0) {
        return [];
      }

      final bases = result.rows.map((row) {
        final rowMap = row.assoc();
        return AllBasesQueryResult(
          nome: rowMap['nome'] ?? '',
          tipo: rowMap['tipo'] ?? '',
        );
      }).toList();

      return bases;
    } on Exception catch (e) {
      print('Erro no DAO ao buscar bases: $e');
      throw Exception('Falha ao acessar o banco de dados.');
    }
  }
}
