import 'dart:convert';
import 'package:mysql_client/mysql_client.dart';


class TransactionDAO {
  final MySQLConnection connection;

  TransactionDAO(this.connection);

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
}
