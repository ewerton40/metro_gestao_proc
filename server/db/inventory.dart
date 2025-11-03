import 'package:mysql_client/mysql_client.dart';

class InventoryItemQueryResult {
  final int id;
  final String nome;
  
  final int categoriaId;    
  final String categoria; 

  final int medidaId;       
  final String medida;     

  final bool requerCalibracao;
  final int qtdAlto;
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
    required this.qtdAlto,
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
          qtdAlto: int.tryParse(data['qtdAlto'] ?? '0') ?? 0,
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
}