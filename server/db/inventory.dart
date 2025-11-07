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


Future<List<Map<String, dynamic>>> getCriticalItems() async {
  const String sqlQuery = '''
    SELECT 
        m.nome AS nome_material,
        e.quantidade
    FROM materiais m
    JOIN estoque e ON m.id_material = e.id_material
    WHERE e.quantidade <= m.qtd_alerta_baixo
    ORDER BY e.quantidade ASC
    LIMIT 5;
  ''';

  try {
    final result = await connection.execute(sqlQuery);

    if (result.numOfRows == 0) return [];

    return result.rows.map((row) {
      final data = row.assoc();
      return {
        'nome_material': data['nome_material'] ?? '',
        'quantidade': int.tryParse(data['quantidade'] ?? '0') ?? 0,
      };
    }).toList();
  } catch (e) {
    print('Erro ao buscar itens críticos: $e');
    throw Exception('Falha ao acessar o banco de dados.');
  }
}
  
  Future<int> registerMovement({
    required int idMaterial,
    required int quantidade,
    required int idLocalDestino,
    required int idFuncionario,
    required String observacao,
  }) async {
    
    await connection.execute('START TRANSACTION');

    try {
      final resultMov = await connection.execute(
        '''
        INSERT INTO movimentacoes 
        (id_material, quantidade, id_local_destino, id_funcionario_responsavel, observacao, tipo_movimentacao, id_local_origem)
        VALUES (:id, :qtd, :destino, :func, :obs, :tipo, NULL)
        ''',
        {
          'id': idMaterial,
          'qtd': quantidade,
          'destino': idLocalDestino,
          'func': idFuncionario,
          'obs': observacao,
          'tipo': 'entrada', 
        },
      );

      final resultBase = await connection.execute(
        'SELECT id_base FROM locais_estoque WHERE id_local = :idLocal',
        {'idLocal': idLocalDestino},
      );
      
      if (resultBase.numOfRows == 0) {
        throw Exception('Local de destino não encontrado ou não associado a uma base.');
      }
      final int idBase = int.parse(resultBase.rows.first.assoc()['id_base']!);

      await connection.execute(
        '''
        INSERT INTO estoque (id_base, id_material, quantidade)
        VALUES (:base, :material, :qtd)
        ON DUPLICATE KEY UPDATE quantidade = quantidade + :qtd
        ''',
        {
          'base': idBase,
          'material': idMaterial,
          'qtd': quantidade,
        },
      );

      await connection.execute('COMMIT');
      
      return resultMov.lastInsertID.toInt();

    } catch (e) {
      await connection.execute('ROLLBACK');
      print('Erro na transação de movimento: $e');
      rethrow; 
    }
  }

  Future<List<Map<String, dynamic>>> getAllLocations() async {
    try {
      final result = await connection.execute(
        '''
        SELECT 
          l.id_local, 
          l.localizacao, 
          b.nome_base 
        FROM locais_estoque l
        JOIN base b ON l.id_base = b.id_base
        ORDER BY b.nome_base, l.localizacao;
        '''
      );
      
      if (result.numOfRows == 0) return [];

      return result.rows.map((row) {
        final data = row.assoc();
        return {
          'id': data['id_local'],
          'nome': '${data['nome_base']} - ${data['localizacao']}',
        };
      }).toList();

    } catch (e) {
      print('Erro no DAO ao buscar locais: $e');
      rethrow;
    }
  }

  Future<int> registerSaida({
    required int idMaterial,
    required int quantidade,
    required int idLocalOrigem,
    required int idFuncionario,
    required String observacao,
  }) async {
    
    await connection.execute('START TRANSACTION');

    try {
      final resultBase = await connection.execute(
        'SELECT id_base FROM locais_estoque WHERE id_local = :idLocal',
        {'idLocal': idLocalOrigem},
      );
      
      if (resultBase.numOfRows == 0) {
        throw Exception('Local de origem não encontrado ou não associado a uma base.');
      }
      final int idBase = int.parse(resultBase.rows.first.assoc()['id_base']!);

      final resultEstoque = await connection.execute(
        '''
        SELECT quantidade FROM estoque
        WHERE id_base = :base AND id_material = :material
        FOR UPDATE
        ''',
        {'base': idBase, 'material': idMaterial},
      );

      int estoqueAtual = 0;
      if (resultEstoque.numOfRows > 0) {
        estoqueAtual = int.parse(resultEstoque.rows.first.assoc()['quantidade']!);
      }

      if (estoqueAtual < quantidade) {
        // Se não tiver estoque, desfaz a transação e retorna erro
        await connection.execute('ROLLBACK');
        throw Exception('Estoque insuficiente. Disponível: $estoqueAtual, Solicitado: $quantidade');
      }

      await connection.execute(
        '''
        UPDATE estoque 
        SET quantidade = quantidade - :qtd
        WHERE id_base = :base AND id_material = :material
        ''',
        {'qtd': quantidade, 'base': idBase, 'material': idMaterial},
      );

      final resultMov = await connection.execute(
        '''
        INSERT INTO movimentacoes 
        (id_material, quantidade, id_local_origem, id_funcionario_responsavel, observacao, tipo_movimentacao, id_local_destino)
        VALUES (:id, :qtd, :origem, :func, :obs, :tipo, NULL)
        ''',
        {
          'id': idMaterial,
          'qtd': quantidade,
          'origem': idLocalOrigem,
          'func': idFuncionario,
          'obs': observacao,
          'tipo': 'saida',
        },
      );

      await connection.execute('COMMIT');
      
      // Retorna o ID da movimentação que acabou de ser criada
      return resultMov.lastInsertID.toInt();

    } catch (e) {
      await connection.execute('ROLLBACK');
      print('Erro na transação de SAÍDA: $e');
      rethrow; 
    }
  }
}





