import 'package:mysql_client/mysql_client.dart';


class CategoryQueryResult{
  final int id_categoria;
  final String nome_categoria;

  CategoryQueryResult(this.id_categoria, this.nome_categoria);
}

class CategoryDAO{

    final MySQLConnection connection;
    CategoryDAO(this.connection);

    Future<List<CategoryQueryResult>> getAllCategories() async {
    const String sqlQuery = '''
      SELECT id_categoria, nome_categoria 
      FROM categoria 
      ORDER BY nome_categoria;
    ''';

    try {
      final result = await connection.execute(sqlQuery);
      if (result.numOfRows == 0) return [];

      final categories = <CategoryQueryResult>[];
      for (final row in result.rows) {
        final data = row.assoc();
        categories.add(CategoryQueryResult(
          int.tryParse(data['id_categoria'] ?? '0') ?? 0,
          data['nome_categoria'] ?? '',
        ));
      }
      return categories;

    } catch (e) {
      print('Erro no DAO ao buscar categorias: $e');
      throw Exception('Falha ao buscar categorias.');
    }
  }

}