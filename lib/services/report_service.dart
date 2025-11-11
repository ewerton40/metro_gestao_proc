import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportService {
  final _baseUrl = 'http://localhost:8080';

  Future<List<Map<String, dynamic>>> fetchMovimentacoes() async {
    final url = Uri.parse('$_baseUrl/reports/movimentacoes');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          return List<Map<String, dynamic>>.from(responseBody['data']);
        } else {
          throw Exception(responseBody['message']);
        }
      } else {
        throw Exception('Falha ao buscar relatório: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchConsumo() async {
    final url = Uri.parse('$_baseUrl/reports/consumo');
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        
        if (responseBody['success'] == true) {
          return List<Map<String, dynamic>>.from(responseBody['data']);
        } else {
          throw Exception(responseBody['message']);
        }
      } else {
        throw Exception('Falha ao buscar relatório: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
