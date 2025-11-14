import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/inventoryscreen.dart';
import '../models/location.dart';

class InventoryServices {
  final _baseUrl = 'http://localhost:8080';


  Future<List<InventoryItem>> getAllItems() async {
    final url = Uri.parse('$_baseUrl/inventory/all');
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
        
        final errorBody = jsonDecode(response.body);
        throw Exception('Falha ao registrar: ${errorBody['message']}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }



 Future<Map<String, dynamic>> addItem(Map<String, dynamic> itemData) async {
    final url = Uri.parse('$_baseUrl/materiais');

    final body = jsonEncode({
      'name': itemData['name'],
      'category': itemData['category'],
      'code': itemData['code'],
  //  'medidaId': itemData['medida'],
      'base': itemData['base'],
      'supplier': itemData['supplier'],
      'validityType': itemData['validityType'],
      'minStock': itemData['minStock'],
      'maxStock': itemData['maxStock'],
      'description': itemData['description'],
      'validityDate': itemData['validityDate'],
    });

    try { 
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
        if (response.statusCode == 201) {
          return jsonDecode(response.body);
        } else {  
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? 'Falha desconhecida (Status: ${response.statusCode}).';
          throw Exception(errorMessage);
        }
    } catch (e) {
      throw Exception('Erro ao conectar ou processar dados: $e');
    }
  }
  

  Future<int> getLowStockCount() async {
  final url = Uri.parse('$_baseUrl/inventory/low_stock');
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
}

