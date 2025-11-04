import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/inventoryscreen.dart';



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
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao buscar categorias: ${response.statusCode} - ${response.body}');
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
}

