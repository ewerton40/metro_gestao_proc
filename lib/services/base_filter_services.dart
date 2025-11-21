import 'dart:convert';
import 'package:http/http.dart' as http;

// esse arquivo foi criado para métodos que utilizam comandos SQL na tela de 
// gráficos filtrados por base, com intuito de evitar a repetição de métodos 
// muito similares nos arquivos inventory/movimentation.dart;;;

class BaseFilterServices {
  final _baseUrl = 'http://localhost:8080';

  Future<List<dynamic>> getBaseMovementsToday(int baseId) async {
  final url = Uri.parse('$_baseUrl/basefilter/$baseId/movtoday');
  try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final data = jsonResponse['data']; 
            return data;
          } else {
            throw Exception('Resposta inesperada do servidor: ${response.body}');
          }
        } else {
          throw Exception(
            'Erro HTTP ${response.statusCode}: ${response.reasonPhrase}',
          );
        }
    }catch(e){
      print("Erro ao obter movimentos de hoje filtrados por base(services): $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getBaseCriticalItens(int baseId) async {
  final url = Uri.parse('$_baseUrl/basefilter/$baseId/critical');

  try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final data = jsonResponse['data']; 
            return data;
          } else {
            throw Exception('Resposta inesperada do servidor: ${response.body}');
          }
        } else {
          throw Exception(
            'Erro HTTP ${response.statusCode}: ${response.reasonPhrase}',
          );
        }
    }catch(e){
      print("Erro ao obter itens críticos filtrados por base(services): $e");
      rethrow;
    }
  }


Future<List<dynamic>> getBaseMonthCalibration(int baseId) async {
  final url = Uri.parse('$_baseUrl/basefilter/$baseId/calibration');

  try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final data = jsonResponse['data']; 
            return data;
          } else {
            throw Exception('Resposta inesperada do servidor: ${response.body}');
          }
        } else {
          throw Exception(
            'Erro HTTP ${response.statusCode}: ${response.reasonPhrase}',
          );
        }
    }catch(e){
      print("Erro ao obter calibracao mensal filtrados por base(services): $e");
      rethrow;
    }
  }


Future<List<dynamic>> getBaseCategoryDistribution(int baseId) async {
  final url = Uri.parse('$_baseUrl/basefilter/$baseId/categories');

  try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data']; 
          return data;
        } else {
          throw Exception('Resposta inesperada do servidor: ${response.body}');
        }
      } else {
        throw Exception(
          'Erro HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
  }catch(e){
    print("Erro ao obter distribuicao por categoria filtrados por base(services): $e");
    rethrow;
  }
}



Future<List<dynamic>> getBaseLowStock(int baseId) async {
  final url = Uri.parse('$_baseUrl/basefilter/$baseId/lowstock');

  try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data']; 
          return data;
        } else {
          throw Exception('Resposta inesperada do servidor: ${response.body}');
        }
      } else {
        throw Exception(
          'Erro HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
  }catch(e){
    print("Erro ao obter itens de baixo estoque filtrados por base(services): $e");
    rethrow;
  }
}

Future<List<dynamic>> getFluxoMensal(int baseId) async {
  final url = Uri.parse('$_baseUrl/basefilter/$baseId/monthlyflow');

  try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final data = jsonResponse['data']; 
            return data;
          } else {
            throw Exception('Resposta inesperada do servidor: ${response.body}');
          }
        } else {
          throw Exception(
            'Erro HTTP ${response.statusCode}: ${response.reasonPhrase}',
          );
        }
    }catch(e){
      print("Erro ao obter itens de baixo estoque filtrados por base(services): $e");
      rethrow;
    }
  }
}



