import 'package:mysql_client/mysql_client.dart';


class MovementsQuant{
  final int entradas;
  final int saidas;
  
  MovementsQuant({required this.entradas, required this.saidas});
  
  Map<String, dynamic> toJson() {
    return {
      'entradas': entradas,
      'saidas': saidas,
    };
  }
}

class TopMaterial {
  final String nome;
  final int totalSaidas;

  TopMaterial({
    required this.nome,
    required this.totalSaidas,
  });
}


class MovimentationDAO {
  final MySQLConnection connection;

  MovimentationDAO(this.connection);

  Future<void> registrarEntrada({
    required int idMaterial,
    required int quantidade,
    required int idBaseDestino,
    required int idFuncionario,
    String? observacao,
  }) async {
    const String sqlInsertMov = '''
      INSERT INTO movimentacoes (
        id_material,
        quantidade,
        tipo_movimentacao,
        id_local_destino,
        id_funcionario_responsavel,
        observacao
      )
      VALUES (:id_material, :quantidade, 'entrada', :id_base_destino, :id_funcionario, :observacao)
    ''';

    const String sqlUpdateEstoque = '''
      INSERT INTO estoque (id_base, id_material, quantidade)
      VALUES (:id_base_destino, :id_material, :quantidade)
      ON DUPLICATE KEY UPDATE quantidade = quantidade + VALUES(quantidade)
    ''';

    try {
      await connection.transactional((txn) async {
        await txn.execute(sqlInsertMov, {
          'id_material': idMaterial,
          'quantidade': quantidade,
          'id_base_destino': idBaseDestino,
          'id_funcionario': idFuncionario,
          'observacao': observacao ?? '',
        });

        await txn.execute(sqlUpdateEstoque, {
          'id_base_destino': idBaseDestino,
          'id_material': idMaterial,
          'quantidade': quantidade,
        });
      });

      print("✅ Entrada registrada com sucesso.");
    } catch (e) {
      print("❌ Erro ao registrar entrada: $e");
      rethrow;
    }
  }

  Future<void> registrarSaida({
    required int idMaterial,
    required int quantidade,
    required int idBaseOrigem,
    required int idFuncionario,
    String? observacao,
  }) async {
    const String sqlInsertMov = '''
      INSERT INTO movimentacoes (
        id_material,
        quantidade,
        tipo_movimentacao,
        id_local_origem,
        id_funcionario_responsavel,
        observacao
      )
      VALUES (:id_material, :quantidade, 'saida', :id_base_origem, :id_funcionario, :observacao)
    ''';

    const String sqlUpdateEstoque = '''
      UPDATE estoque
      SET quantidade = quantidade - :quantidade
      WHERE id_base = :id_base_origem AND id_material = :id_material
    ''';

    const String sqlCheckEstoque = '''
      SELECT quantidade FROM estoque 
      WHERE id_base = :id_base_origem AND id_material = :id_material
    ''';

    try {
      await connection.transactional((txn) async {
        await txn.execute(sqlInsertMov, {
          'id_material': idMaterial,
          'quantidade': quantidade,
          'id_base_origem': idBaseOrigem,
          'id_funcionario': idFuncionario,
          'observacao': observacao ?? '',
        });

        await txn.execute(sqlUpdateEstoque, {
          'quantidade': quantidade,
          'id_base_origem': idBaseOrigem,
          'id_material': idMaterial,
        });

        final checkResult = await txn.execute(sqlCheckEstoque, {
          'id_base_origem': idBaseOrigem,
          'id_material': idMaterial,
        });

        final row = checkResult.rows.first.assoc();
        final novaQtd = int.parse(row['quantidade'] ?? '0');

        if (novaQtd < 0) {
          throw Exception('Quantidade insuficiente em estoque.');
        }
      });

      print("✅ Saída registrada com sucesso.");
    } catch (e) {
      print("❌ Erro ao registrar saída: $e");
      rethrow;
    }
  }

  Future<MovementsQuant?> movementsToday() async{
    String sqlQuery = '''
      SELECT
      SUM(CASE WHEN tipo_movimentacao = 'entrada' THEN 1 ELSE 0 END) AS entradas,
      SUM(CASE WHEN tipo_movimentacao = 'saida' THEN 1 ELSE 0 END) AS saidas
      FROM movimentacoes
      WHERE DATE(data_movimentacao) = CURDATE()
''';
    try{
      final result =  await connection.execute(sqlQuery);
      if(result.numOfRows == 0){
      return null;
      }
      final data = result.rows.first.assoc();
      final entradas = int.tryParse(data['entradas'] ?? '0') ?? 0;
      final saidas = int.tryParse(data['saidas'] ?? '0') ?? 0;

      return MovementsQuant(entradas: entradas, saidas: saidas);
    }catch(e){
      print("Erro ao buscar Movimentacoes de hoje :$e");
      return null;
    }

  }

  Future<List<TopMaterial>> getTopFiveUsedMaterials() async {
  const String sqlQuery = '''
    SELECT 
        m.nome AS material,
        COUNT(*) AS total_saidas
    FROM movimentacoes mov
    JOIN materiais m ON mov.id_material = m.id_material
    WHERE mov.tipo_movimentacao = 'saida'
    GROUP BY m.id_material
    ORDER BY total_saidas DESC
    LIMIT 5;
  ''';

  try {
    final result = await connection.execute(sqlQuery);

    if (result.numOfRows == 0) {
      return [];
    }

    return result.rows.map((row) {
      final data = row.assoc();
      return TopMaterial(
        nome: data['material'] ?? '',
        totalSaidas: int.tryParse(data['total_saidas'] ?? '0') ?? 0,
      );
    }).toList();
  } catch (e) {
    print("Erro ao buscar os materiais mais usados: $e");
    return [];
  }
}
}