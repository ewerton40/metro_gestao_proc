import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/inventoryscreen.dart';
import '../utils/models/location.dart';

class InventoryServices {
  final _baseUrl = 'http://localhost:8080';


  Future<List<InventoryItem>> getAllItems({int? baseId}) async { 
    
    var urlString = '$_baseUrl/inventory/all';
    if (baseId != null) {
      urlString += '?baseId=$baseId'; 
    }
    final url = Uri.parse(urlString);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => InventoryItem.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao buscar itens: ${response.statusCode} - ${response.body}');
    }
  }


Future<List<Category>> getAllCategories() async {
  final url = Uri.parse('$_baseUrl/categories');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final List<dynamic> data = jsonResponse['data']; 
    final List<Category> categories =
        data.map((item) => Category.fromJson(item)).toList();
    return categories;
  } else {
    throw Exception('Failed to load categories. Status code: ${response.statusCode}');
  }
}
    
  Future<Map<String, dynamic>> registerMovement({
    required int idMaterial,
    required int quantidade,
    required int idLocalDestino,
    required int idFuncionario,
    required String observacao,
  }) async {
    
    final url = Uri.parse('$_baseUrl/movimentations/add');

    final body = jsonEncode({
      'id_material': idMaterial,
      'quantidade': quantidade,
      'id_local_destino': idLocalDestino,
      'id_funcionario': idFuncionario, 
      'observacao': observacao,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // Tenta decodificar a mensagem de erro do servidor
        final errorBody = jsonDecode(response.body);
        throw   ('Falha ao registrar: ${errorBody['message']}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }



 Future<Map<String, dynamic>> addItem(InventoryItem item) async {
    final url = Uri.parse('$_baseUrl/inventory/add');

    final body = jsonEncode({
      'nome': item.nome,
      'categoriaId': item.categoriaId,
      'medidaId': item.medidaId,
      'requerCalibracao': item.calibracao,
      'qtdAlto': item.qtdAlto,
      'qtdBaixo': item.qtdBaixo,
      'descricao': item.descricao,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao cadastrar item: ${response.statusCode} - ${response.body}');
    }
  }

  Future<int> getLowStockCount() async {
  final url = Uri.parse('$_baseUrl/inventory/lowstock');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success'] == true) {
      return jsonResponse['data']['lowStockCount'] ?? 0;
    } else {
      throw Exception('Erro: ${jsonResponse['error']}');
    }
  } else {
    throw Exception('Falha na requisição: ${response.statusCode}');
  }
}


Future<int> getTotalItemsCount() async {
  final url = Uri.parse('$_baseUrl/inventory/all');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (jsonResponse['success'] == true) {
      final count = jsonResponse['count'];
      return count is int ? count : int.tryParse(count.toString()) ?? 0;
    } else {
      throw Exception('Erro na resposta: ${jsonResponse['message']}');
    }
  } else {
    throw Exception('Falha ao obter total de itens: ${response.statusCode}');
  }
}


Future<List<Map<String, dynamic>>> getCriticalItems() async {
  final url = Uri.parse('$_baseUrl/inventory/critical');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success'] == true) {
      return List<Map<String, dynamic>>.from(jsonResponse['data']);
    } else {
      throw Exception('Erro: ${jsonResponse['error']}');
    }
  } else {
    throw Exception('Falha ao buscar itens críticos: ${response.statusCode}');
  }
}

  Future<List<SimpleLocation>> getAllLocations() async {
    final url = Uri.parse('$_baseUrl/locations'); 
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return data.map((item) => SimpleLocation.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao buscar locais');
    }
  }


  Future<Map<String, dynamic>> getItemDetail(int idMaterial) async {
  final url = Uri.parse('$_baseUrl/inventory/itensdetails/$idMaterial');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success'] == true) {
      return jsonResponse['data'];
    } else {
      throw Exception(jsonResponse['message'] ?? 'Erro ao buscar detalhes do item.');
    }
  } else {
    throw Exception('Falha ao buscar detalhes do item: ${response.statusCode}');
  }
}

Future<List<Map<String, dynamic>>> getMaterialsDistributionByCategory() async {
  final url = Uri.parse('$_baseUrl/inventory/distribution');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success'] == true) {
      return List<Map<String, dynamic>>.from(jsonResponse['data']);
    } else {
      throw Exception(jsonResponse['message'] ?? 'Erro ao buscar distribuição de materiais.');
    }
  } else {
    throw Exception('Falha ao buscar distribuição: ${response.statusCode}');
  }
}
  Future<Map<String, dynamic>> registerSaida({
    required int idMaterial,
    required int quantidade,
    required int idLocalOrigem,
    required int idFuncionario,
    required String observacao,
  }) async {
    
    final url = Uri.parse('$_baseUrl/movimentations/exit'); 

    final body = jsonEncode({
      'id_material': idMaterial,
      'quantidade': quantidade,
      'id_local_origem': idLocalOrigem,
      'id_funcionario': idFuncionario,
      'observacao': observacao,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception(responseBody['message']);
      }
    } catch (e) {
      throw Exception('Erro de conexão ao registrar saída: $e');
    }

}

}