import 'package:mysql_client/mysql_client.dart';

class InventoryItemQueryResult {
  final int id;
  final String nome;
  
  final int categoriaId;    
  final String categoria; 

  final int medidaId;       
  final String medida;     

  final bool requerCalibracao;
  final int qtdAtual;
  final int qtdBaixo;
  final String descricao;

  InventoryItemQueryResult({
    required this.id,
    required this.nome,
    required this.categoriaId, 
    required this.categoria,
    required this.medidaId,   
    required this.medida,
    required this.requerCalibracao,
    required this.qtdAtual,
    required this.qtdBaixo,
    required this.descricao,
  });
}


class InventoryDAO {
  final MySQLConnection connection;
  InventoryDAO(this.connection);

  Future<List<InventoryItemQueryResult>> getAllItems() async {
    const String sqlQuery = '''
      SELECT 
        m.id_material AS id,
        m.nome AS nome,
        
        m.id_categoria AS categoriaId,      
        c.nome_categoria AS categoria,
        
        m.id_medida AS medidaId,
        u.nome_medida AS medida,
        
        m.requer_calibracao AS requerCalibracao,
        m.qtd_alto AS qtdAlto,
        m.qtd_alerta_baixo AS qtdBaixo,
        m.descricao AS descricao
      FROM materiais m
      LEFT JOIN categoria c ON m.id_categoria = c.id_categoria
      LEFT JOIN unidade_medida u ON m.id_medida = u.id_medida;
    ''';

    try {
      final result = await connection.execute(sqlQuery);
      if (result.numOfRows == 0) return [];

      final items = <InventoryItemQueryResult>[];
      for (final row in result.rows) {
        final data = row.assoc();
        items.add(InventoryItemQueryResult(
          id: int.tryParse(data['id'] ?? '0') ?? 0,
          nome: data['nome'] ?? '',
          
          categoriaId: int.tryParse(data['categoriaId'] ?? '0') ?? 0, 
          categoria: data['categoria'] ?? '',
          medidaId: int.tryParse(data['medidaId'] ?? '0') ?? 0,       
          medida: data['medida'] ?? '',
          
          requerCalibracao: data['requerCalibracao'] == '1',
          qtdAtual: int.tryParse(data['qtdAlto'] ?? '0') ?? 0,
          qtdBaixo: int.tryParse(data['qtdBaixo'] ?? '0') ?? 0,
          descricao: data['descricao'] ?? '',
        ));
    }
      return items;
    } catch (e) {
      print('Erro no DAO ao buscar materiais: $e');
      throw Exception('Falha ao acessar o banco de dados.');
  }
  }

  Future<List<InventoryItemQueryResult>> getFilteredItems({
    int? categoriaId,
    String? statusEstoque, 
    String? termoPesquisa,
  }) async {
    

    String sqlQuery = '''
      SELECT 
        m.id_material AS id,
        m.nome AS nome,
        m.id_categoria AS categoriaId,       
        c.nome_categoria AS categoria,
        m.id_medida AS medidaId,       
        u.nome_medida AS medida,
        m.requer_calibracao AS requerCalibracao,
        m.qtd_atual AS qtdAtual,         -- Corrigido
        m.qtd_alerta_baixo AS qtdBaixo,
        m.descricao AS descricao
      FROM materiais m
      LEFT JOIN categoria c ON m.id_categoria = c.id_categoria
      LEFT JOIN unidade_medida u ON m.id_medida = u.id_medida
    ''';

    List<String> whereClauses = [];
    List<dynamic> parameters = [];

   
    if (categoriaId != null) {
      whereClauses.add('m.id_categoria = ?');
      parameters.add(categoriaId);
    }

    if (termoPesquisa != null && termoPesquisa.isNotEmpty) {
      whereClauses.add('m.nome LIKE ?');
      parameters.add('%$termoPesquisa%'); 
    }

    if (statusEstoque != null) {
      switch (statusEstoque) {
        case 'Em estoque':
          // Atual > Baixo
          whereClauses.add('m.qtd_atual > m.qtd_alerta_baixo');
          break;
        case 'Baixo estoque':
          // Atual > 0 E Atual <= Baixo
          whereClauses.add('m.qtd_atual > 0 AND m.qtd_atual <= m.qtd_alerta_baixo');
          break;
        case 'Esgotado':
          // Atual <= 0
          whereClauses.add('m.qtd_atual <= 0');
          break;
      }
    }

    if (whereClauses.isNotEmpty) {
      sqlQuery += ' WHERE ${whereClauses.join(' AND ')}';
    }

    // Adiciona ordenação
    sqlQuery += ' ORDER BY m.nome;';

    try {

      final result = await connection.execute(sqlQuery);

      if (result.numOfRows == 0) return [];

      final items = <InventoryItemQueryResult>[];
      for (final row in result.rows) {
        final data = row.assoc();
        items.add(InventoryItemQueryResult(
          id: int.tryParse(data['id'] ?? '0') ?? 0,
          nome: data['nome'] ?? '',
          categoriaId: int.tryParse(data['categoriaId'] ?? '0') ?? 0, 
          categoria: data['categoria'] ?? '',
          medidaId: int.tryParse(data['medidaId'] ?? '0') ?? 0,     
          medida: data['medida'] ?? '',
          requerCalibracao: data['requerCalibracao'] == '1',
          qtdAtual: int.tryParse(data['qtdAtual'] ?? '0') ?? 0, 
          qtdBaixo: int.tryParse(data['qtdBaixo'] ?? '0') ?? 0,
          descricao: data['descricao'] ?? '',
        ));
      }
      return items;
    } catch (e) {
      print('Erro no DAO ao buscar materiais filtrados: $e');
      throw Exception('Falha ao acessar o banco de dados.');
    }
  }
  
   Future<int> countLowStockItems() async {
    const String sqlQuery = '''
      SELECT 
        COUNT(*) AS itens_baixo_estoque
      FROM materiais m
      JOIN estoque e ON m.id_material = e.id_material
      WHERE e.quantidade <= m.qtd_alerta_baixo;
    ''';

    try {
      final result = await connection.execute(sqlQuery);

      if (result.numOfRows == 0) return 0;

      final row = result.rows.first.assoc();
      final count = int.tryParse(row['itens_baixo_estoque'] ?? '0') ?? 0;

      return count;
    } catch (e) {
      print('Erro ao contar itens de baixo estoque: $e');
      throw Exception('Falha ao acessar o banco de dados.');
    }
  }
}


