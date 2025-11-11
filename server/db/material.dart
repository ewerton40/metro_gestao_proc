

import 'package:mysql_client/mysql_client.dart';
import 'connection.dart'; 
class MaterialDAO {
  final MySQLConnection _conn;

  MaterialDAO(this._conn);

  
  Future<int> _getCategoriaId(MySQLConnection conn, String categoryName) async {
    final results = await conn.execute(
      
      'SELECT id_categoria FROM categoria WHERE nome_categoria = :category',
      {'category': categoryName}, 
    );

    if (results.rows.isEmpty) {
      throw Exception('Categoria não encontrada: $categoryName. Verifique a tabela `categoria`.');
    }

    
    final idCategoriaString = results.rows.first.colByName('id_categoria');

    if (idCategoriaString == null) {
      throw Exception('ID de Categoria é nulo para $categoryName.');
    }

    
    final idCategoria = int.tryParse(idCategoriaString.toString());

    if (idCategoria == null) {
      throw Exception('Falha ao converter ID de Categoria ($idCategoriaString) para inteiro.');
    }

    return idCategoria;
  }

  
  Future<int> _getBaseId(MySQLConnection conn, String nomeBase) async {
    final results = await conn.execute(
      'SELECT id_local FROM locais_estoque WHERE localizacao = :nome',
      {'nome': nomeBase},
    );
    
    if (results.rows.isEmpty) {
      throw Exception('Base não encontrada: $nomeBase. Verifique a tabela `locais_estoque`.');
    }
    
    
    final idBaseString = results.rows.first.colByName('id_local');

    if (idBaseString == null) {
      throw Exception('ID de Localização é nulo para $nomeBase.');
    }

    final idBase = int.tryParse(idBaseString.toString()); 
    
    if (idBase == null) {
      throw Exception('Falha ao converter ID de Localização ($idBaseString) para inteiro.');
    }

    return idBase;
  }

  
  Future<void> saveNewMaterial({
    required String name,
    required String code, 
    required String category,
    required String base,
    required String supplier,
    required String validityType,
    required int minStock,
    required int maxStock,
    required String description,
    String? validityDate,
  }) async {
    await _conn.transactional((conn) async {
      
      final idCategoria = await _getCategoriaId(conn, category);
      final idBase = await _getBaseId(conn, base);

      final requerCalibracao = validityType == 'tem validade ou calibração';

      
      final materialResult = await conn.execute(
        '''
        INSERT INTO materiais (
          nome, codigo_material, fornecedor, id_categoria,
          requer_calibracao, qtd_alto, qtd_alerta_baixo, DESCRICAO
        ) VALUES (:name, :code, :supplier, :id_categoria,
                  :requer_calibracao, :qtd_alto, :qtd_alerta_baixo, :descricao)
        ''',
        {
          'name': name,
          'code': code, 
          'supplier': supplier,
          'id_categoria': idCategoria,
          'requer_calibracao': requerCalibracao,
          'qtd_alto': maxStock,
          'qtd_alerta_baixo': minStock,
          'descricao': description,
        },
      );

      final idMaterial = materialResult.lastInsertID;

      if (idMaterial == null) {
        throw Exception('Falha ao obter o ID do material inserido.');
      }

      
      await conn.execute(
        'INSERT INTO estoque (id_base, id_material, quantidade) VALUES (:id_base, :id_material, :quantidade)',
        {
          'id_base': idBase,
          'id_material': idMaterial,
          'quantidade': maxStock
        }
      );
    });
  }
}