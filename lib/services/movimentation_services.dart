import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/dashBoardScreen.dart';

class MovimentationServices {
  final _baseUrl = 'http://localhost:8080';

  Future<MovementsToday> getMovementsToday() async {
    final url = Uri.parse('$_baseUrl/movimentations/movtoday');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data']; 
          return MovementsToday.fromJson(data);
        } else {
          throw Exception('Resposta inesperada do servidor: ${response.body}');
        }
      } else {
        throw Exception(
          'Erro HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    }catch (e) {
      print('Erro ao obter movimentações de hoje: $e');
      rethrow;
    }
}


 Future<List<Map<String, dynamic>>> getTop5Materials() async {
    final response = await http.get(Uri.parse('$_baseUrl/movimentation/fiveused'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((e) => {
        'material': e['material'],
        'total_saidas': e['total_saidas'],
      }).toList();
    } else {
      throw Exception('Erro ao buscar top 5 materiais');
    }
  }
}


