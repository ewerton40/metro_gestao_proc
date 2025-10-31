import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';

/// Modelo de dados compatível com o backend Dart Frog
class InventoryItem {
  final int code;
  final String nome;
  final int categoria;
  final int medida;
  final bool calibracao;
  final int qtdAlto;
  final int qtdBaixo;
  final String descricao;

  InventoryItem({
    required this.code,
    required this.nome,
    required this.categoria,
    required this.medida,
    required this.calibracao,
    required this.qtdAlto,
    required this.qtdBaixo,
    required this.descricao,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      code: int.tryParse(json['code'].toString()) ?? 0,
      nome: json['nome'] ?? '',
      categoria: int.tryParse(json['categoria'].toString()) ?? 0,
      medida: int.tryParse(json['medida'].toString()) ?? 0,
      calibracao: json['calibracao'].toString() == '1' ||
          json['calibracao'].toString().toLowerCase() == 'true',
      qtdAlto: int.tryParse(json['qtdAlto'].toString()) ?? 0,
      qtdBaixo: int.tryParse(json['qtdBaixo'].toString()) ?? 0,
      descricao: json['descricao'] ?? '',
    );
  }
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Filtros selecionados
  String? _selectedStatus;
  String? _selectedCategory;
  String _searchText = '';

  // Opções de filtro
  final List<String> _statusOptions = ['Todos', 'Em estoque', 'Baixo estoque', 'Esgotado'];
  final List<String> _categoryOptions = ['Todas', '1', '2', '3']; // IDs de categoria

  // Dados da API
  List<InventoryItem> _items = [];

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchInventoryItems();
  }

  Future<void> _fetchInventoryItems() async {
    final url = Uri.parse('http://localhost:8080/inventory'); // endpoint do backend

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _items = data.map((json) => InventoryItem.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar dados do servidor.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro de rede: $e');
      setState(() {
        _errorMessage = 'Erro de conexão. Verifique sua rede ou o servidor.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Aplica os filtros sobre os itens carregados
    List<InventoryItem> filteredItems = _applyFilters(_items);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const BarMenu(),
      drawer: const VerticalMenu(),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchAndFilters(),
            const SizedBox(height: 24),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        )
                      : _buildDataTable(filteredItems),
            ),

            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // --- FILTROS ---
  List<InventoryItem> _applyFilters(List<InventoryItem> items) {
    List<InventoryItem> filtered = items;

    // Filtro por categoria
    if (_selectedCategory != null && _selectedCategory != 'Todas') {
      filtered = filtered
          .where((item) => item.categoria.toString() == _selectedCategory)
          .toList();
    }

    // Filtro por status (estoque)
    if (_selectedStatus != null && _selectedStatus != 'Todos') {
      filtered = filtered.where((item) {
        if (_selectedStatus == 'Em estoque') {
          return item.qtdAlto > item.qtdBaixo;
        } else if (_selectedStatus == 'Baixo estoque') {
          return item.qtdAlto <= item.qtdBaixo && item.qtdAlto > 0;
        } else if (_selectedStatus == 'Esgotado') {
          return item.qtdAlto == 0;
        }
        return true;
      }).toList();
    }

    // Filtro de busca (nome)
    if (_searchText.isNotEmpty) {
      filtered = filtered
          .where((item) => item.nome.toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  // --- UI ---
  Widget _buildHeader() {
    return const Row(
      children: [
        Text(
          'Inventário',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _searchText = value),
          decoration: InputDecoration(
            hintText: 'Pesquisar item...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedCategory,
                hint: 'Todas',
                items: _categoryOptions,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = (newValue == 'Todas') ? null : newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedStatus,
                hint: 'Todos',
                items: _statusOptions,
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatus = (newValue == 'Todos') ? null : newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value ?? hint,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildDataTable(List<InventoryItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
          columns: const [
            DataColumn(label: Text('Código')),
            DataColumn(label: Text('Nome')),
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Medida')),
            DataColumn(label: Text('Qtd. Alta')),
            DataColumn(label: Text('Qtd. Baixa')),
            DataColumn(label: Text('Calibração')),
          ],
          rows: items.map((item) {
            return DataRow(cells: [
              DataCell(Text(item.code.toString())),
              DataCell(Text(item.nome)),
              DataCell(Text(item.categoria.toString())),
              DataCell(Text(item.medida.toString())),
              DataCell(Text(item.qtdAlto.toString())),
              DataCell(Text(item.qtdBaixo.toString())),
              DataCell(
                Icon(
                  item.calibracao ? Icons.check_circle : Icons.cancel,
                  color: item.calibracao ? Colors.green : Colors.red,
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1763A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Visualizar Item'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1763A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cadastrar Itens'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total de itens cadastrados: 160', style: TextStyle(color: Colors.grey)),
            Text('Total de itens críticos: 20', style: TextStyle(color: Colors.grey)),
            Text('Última atualização, 02/01/2024', style: TextStyle(color: Colors.grey)),
          ],
        )
      ],
    );
  }
}
