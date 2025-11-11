import 'package:mysql_client/mysql_client.dart';

class Notificacao {
  final int id;
  final String mensagem;
  final String dataCriacao;
  final bool lida;

  Notificacao({
    required this.id,
    required this.mensagem,
    required this.dataCriacao,
    required this.lida,
  });
}

class NotificationDAO {
  final MySQLConnection connection;
  NotificationDAO(this.connection);

  /// Busca as 50 notificações mais recentes (lidas ou não)
  Future<List<Notificacao>> getNotifications() async {
    const String sqlQuery = '''
      SELECT id_notificacao, mensagem, data_criacao, lida
      FROM notificacoes
      ORDER BY data_criacao DESC
      LIMIT 50;
    ''';
    
    try {
      final result = await connection.execute(sqlQuery);
      if (result.numOfRows == 0) return [];

      return result.rows.map((row) {
        final data = row.assoc();
        return Notificacao(
          id: int.parse(data['id_notificacao']!),
          mensagem: data['mensagem'] ?? '',
          dataCriacao: data['data_criacao'] ?? '',
          lida: data['lida'] == '1',
        );
      }).toList();

    } catch (e) {
      print('Erro no DAO ao buscar notificações: $e');
      rethrow;
    }
  }

  /// Conta quantas notificações ainda não foram lidas
  Future<int> getUnreadCount() async {
    const String sqlQuery = '''
      SELECT COUNT(*) AS unread_count
      FROM notificacoes
      WHERE lida = 0;
    ''';
    
    try {
      final result = await connection.execute(sqlQuery);
      if (result.numOfRows == 0) return 0;
      
      final data = result.rows.first.assoc();
      return int.parse(data['unread_count'] ?? '0');

    } catch (e) {
      print('Erro no DAO ao contar notificações não lidas: $e');
      rethrow;
    }
  }

  /// Marca todas as notificações como lidas
  Future<bool> markAllAsRead() async {
    const String sqlQuery = '''
      UPDATE notificacoes
      SET lida = 1
      WHERE lida = 0;
    ''';
    
    try {
      final result = await connection.execute(sqlQuery);
      // Retorna true se alguma linha foi de fato alterada
      return result.affectedRows > BigInt.zero;
    } catch (e) {
      print('Erro no DAO ao marcar notificações como lidas: $e');
      rethrow;
    }
  }
}