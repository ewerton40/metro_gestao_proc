import 'package:mysql_client/mysql_client.dart';

// esse arquivo foi criado para métodos que utilizam comandos SQL na tela de 
// gráficos filtrados por base, com intuito de evitar a repetição de métodos 
// muito similares nos arquivos inventory/movimentation.dart;;;

class BaseFilterDAO {
  final MySQLConnection connection;

  BaseFilterDAO(this.connection);

  Future<List<Map<String, dynamic>>> getBaseMovementsToday(int baseId) async {
    const sql = '''
        SELECT
          SUM(CASE WHEN m.tipo_movimentacao = 'entrada' THEN 1 ELSE 0 END) AS entradas,
          SUM(CASE WHEN m.tipo_movimentacao = 'saida' THEN 1 ELSE 0 END) AS saidas
        FROM movimentacoes m
        JOIN locais_estoque le 
            ON m.id_local_origem = le.id_local 
            OR m.id_local_destino = le.id_local
        WHERE le.id_base = :baseId
          AND DATE(m.data_movimentacao) = CURDATE();
    ''';

    try {
      final result = await connection.execute(sql, {'baseId': baseId});
      return result.rows.map((row) => row.assoc()).toList();
    } catch (e) {
      print('Erro no DAO ao buscar movimentações de hoje por base: $e');
      throw Exception('Falha ao buscar movimentações de hoje.');
    }
  }

  Future<List<Map<String, dynamic>>> getBaseCriticalItens(int baseId) async {
    const sql = '''
    SELECT 
      m.nome AS nome_material,
      e.quantidade
      FROM materiais m
      JOIN estoque e ON m.id_material = e.id_material
      WHERE e.id_base = :baseId
        AND e.quantidade <= m.qtd_alerta_baixo
      ORDER BY e.quantidade ASC
      LIMIT 5;
  ''';

    try {
      final result = await connection.execute(sql, {'baseId': baseId});
      return result.rows.map((r) => r.assoc()).toList();
    } catch (e) {
      print('Erro no DAO ao buscar itens críticos por base: $e');
      throw Exception('Falha ao buscar itens críticos.');
    }
  }

  Future<List<Map<String, dynamic>>> getBaseMonthCalibration(int baseId) async {
    const sql = '''
    SELECT 
      MONTH(ip.data_proxima_calibracao) AS mes,
      COUNT(*) AS total
    FROM itens_patrimoniados ip
    JOIN locais_estoque le ON ip.id_local_atual = le.id_local
    WHERE le.id_base = :baseId
      AND ip.data_proxima_calibracao IS NOT NULL
    GROUP BY mes
    ORDER BY mes;
  ''';

    try {
      final result = await connection.execute(sql, {'baseId': baseId});
      return result.rows.map((r) => r.assoc()).toList();
    } catch (e) {
      print('Erro no DAO ao buscar calibrações mensais por base: $e');
      throw Exception('Falha ao buscar calibrações mensais.');
    }
  }

  Future<List<Map<String, dynamic>>> getBaseCategoryDistribution(int baseId) async {
    const sql = '''
    SELECT 
    c.nome_categoria AS categoria,
    COUNT(m.id_material) AS total
    FROM materiais m
    LEFT JOIN categoria c ON m.id_categoria = c.id_categoria
    LEFT JOIN estoque e ON e.id_material = m.id_material
    WHERE e.id_base = :baseId
    GROUP BY c.nome_categoria
    ORDER BY COUNT(m.id_material) DESC;
  ''';

    try {
      final result = await connection.execute(sql, {'baseId': baseId});
      return result.rows.map((r) => r.assoc()).toList();
    } catch (e) {
      print('Erro no DAO ao buscar distribuição por categoria por base: $e');
      throw Exception('Falha ao buscar distribuição por categoria.');
    }
  }

  Future<List<Map<String, dynamic>>> getBaseLowStock(int baseId) async {
    const sql = '''
  SELECT 
    m.nome AS nome_material,
    SUM(e.quantidade) AS quantidade
    FROM materiais m
    LEFT JOIN estoque e 
          ON m.id_material = e.id_material
          AND e.id_base = :baseId              
    GROUP BY m.id_material, m.nome
    HAVING SUM(e.quantidade) <= COALESCE(m.qtd_alerta_baixo, 999999)
    ORDER BY quantidade ASC
    LIMIT 5;
  ''';

    try {
      final result = await connection.execute(sql, {'baseId': baseId});
      return result.rows.map((r) => r.assoc()).toList();
    } catch (e) {
      print('Erro no DAO ao buscar estoque baixo por base: $e');
      throw Exception('Falha ao buscar estoque baixo.');
    }
  }

  Future<List<Map<String, dynamic>>> getBaseMonthlyFlow(int baseId) async {
    const sql = '''
   SELECT
    DATE_FORMAT(m.data_movimentacao, '%b') AS mes,
    SUM(CASE WHEN m.tipo_movimentacao = 'entrada' THEN m.quantidade ELSE 0 END) AS total_entradas,
    SUM(CASE WHEN m.tipo_movimentacao = 'saida' THEN m.quantidade ELSE 0 END) AS total_saidas
    FROM movimentacoes m
    JOIN locais_estoque le 
          ON m.id_local_destino = le.id_local 
          OR m.id_local_origem = le.id_local
    WHERE le.id_base = :baseId
    GROUP BY MONTH(m.data_movimentacao), DATE_FORMAT(m.data_movimentacao, '%b')
    ORDER BY MONTH(m.data_movimentacao);
  ''';

    try {
      final result = await connection.execute(sql, {'baseId': baseId});
      return result.rows.map((r) => r.assoc()).toList();
    } catch (e) {
      print('Erro no DAO ao buscar fluxo mensal por base: $e');
      throw Exception('Falha ao buscar fluxo mensal.');
    }
  }
}