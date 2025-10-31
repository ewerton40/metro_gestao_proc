import 'package:mysql_client/mysql_client.dart';

class InventoryItemQueryResult {
  final String code;
  final String name;
  final String category;
  final String status;
  final String base;
  final String lastMoved;

  InventoryItemQueryResult({
    required this.code,
    required this.name,
    required this.category,
    required this.status,
    required this.base,
    required this.lastMoved,
  });
}

class InventoryDAO {
  final MySQLConnection connection;
  InventoryDAO(this.connection);

  Future<List<InventoryItemQueryResult>> getAllItems() async {
    const String sqlQuery = '''
      SELECT code, name, category, status, base, lastMoved
      FROM inventory_items
    ''';

    try {
      final result = await connection.execute(sqlQuery);

      if (result.numOfRows == 0) {
        return [];
      }

      final items = <InventoryItemQueryResult>[];
      for (final row in result.rows) {
        final rowMap = row.assoc();
        items.add(
          InventoryItemQueryResult(
            code: rowMap['code'] ?? '',
            name: rowMap['name'] ?? '',
            category: rowMap['category'] ?? '',
            status: rowMap['status'] ?? '',
            base: rowMap['base'] ?? '',
            lastMoved: rowMap['lastMoved'] ?? '',
          ),
        );
      }

      return items;
    } on Exception catch (e) {
      print('Erro no DAO ao buscar inventário: $e');
      throw Exception('Falha ao acessar o banco de dados.');
    }
  }
}
