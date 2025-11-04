import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../services/inventory_service.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';

class InventoryItem {
  final int code;
  final String nome;
  final int categoriaId;
  
  final int medidaId;             
  final String medidaNome;         
  
  final bool calibracao;
  final int qtdAlto;
  final int qtdBaixo;
  final String descricao;
  final String categoriaNome;

  InventoryItem({
    required this.code,
    required this.nome,
    required this.categoriaId,
    
    required this.medidaId,      
    required this.medidaNome,
    
    required this.calibracao,
    required this.qtdAlto,
    required this.qtdBaixo,
    required this.descricao,
    required this.categoriaNome,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      code: int.tryParse(json['id'].toString()) ?? 0,
      
      nome: json['nome'] ?? '',
      
      categoriaId: int.tryParse(json['categoriaId'].toString()) ?? 0,
      categoriaNome: json['categoriaNome'] ?? '', 

      medidaId: int.tryParse(json['medidaId'].toString()) ?? 0,
      medidaNome: json['medidaNome'] ?? '', 

      calibracao: json['requerCalibracao'] ?? false,
      
      qtdAlto: int.tryParse(json['qtdAlto'].toString()) ?? 0,
      qtdBaixo: int.tryParse(json['qtdBaixo'].toString()) ?? 0,
      descricao: json['descricao'] ?? '',
    );
  }
}

class Category {
  final int id;
  final String nome;

  Category({required this.id, required this.nome});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nome: json['nome'] ?? '',
    );
  }
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItem> _items = [];
  List<Category> _categories = [];
  InventoryServices inventario = InventoryServices();

  // Filtros selecionados
  String? _selectedStatus;
  Category? _selectedCategory;
  String _searchText = '';

  final List<String> _statusOptions = ['Todos', 'Em estoque', 'Baixo estoque', 'Esgotado'];

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        inventario.getAllItems(),
        inventario.getAllCategories(),
      ]);

      setState(() {
        _items = results[0] as List<InventoryItem>;
        _categories = results[1] as List<Category>;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        _errorMessage = 'Erro ao carregar dados do servidor.';
        _isLoading = false;
      });
    }
  }


  // --- FILTROS 
  List<InventoryItem> _applyFilters(List<InventoryItem> items) {
    List<InventoryItem> filtered = items;

    // Filtro por categoria
    if (_selectedCategory != null) {
      filtered =
          filtered.where((item) => item.categoriaId == _selectedCategory!.id).toList();
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

    // Filtro de busca
    if (_searchText.isNotEmpty) {
      filtered = filtered
          .where((item) => item.nome.toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
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
                          child: Text(_errorMessage,
                              style:
                                  const TextStyle(color: Colors.red, fontSize: 16)))
                      : _buildDataTable(filteredItems),
            ),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Inventário',
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
              child: _buildCategoryDropdown(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatusDropdown(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<Category>(
      value: _selectedCategory,
      hint: const Text('Todas as categorias'),
      items: [
        const DropdownMenuItem<Category>(
          value: null,
          child: Text('Todas as categorias'),
        ),
        ..._categories.map(
          (cat) => DropdownMenuItem<Category>(
            value: cat,
            child: Text(cat.nome),
          ),
        ),
      ],
      onChanged: (newValue) => setState(() => _selectedCategory = newValue),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus ?? 'Todos',
      items: _statusOptions.map((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (newValue) => setState(() => _selectedStatus = newValue),
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
    // ... (decoration)
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        // ... (headingRowColor, columns)
        
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
            DataCell(Text(item.categoriaNome.isNotEmpty
                ? item.categoriaNome
                : item.categoriaId.toString())),
            
            DataCell(Text(item.medidaNome)), 
            DataCell(Text(item.qtdAlto.toString())),
            DataCell(Text(item.qtdBaixo.toString())),
            DataCell(Icon(
              item.calibracao ? Icons.check_circle : Icons.cancel,
              color: item.calibracao ? Colors.green : Colors.red,
            )),
          ]);
        }).toList(),
      ),
    ),
  );
}

  Widget _buildFooter() {
  // Cálculos dinâmicos
  int totalItens = _items.length;
  
  // Usa a mesma lógica do filtro de "Baixo Estoque" e "Esgotado"
  int itensCriticos = _items.where((item) {
    bool baixoEstoque = item.qtdAlto <= item.qtdBaixo && item.qtdAlto > 0;
    bool esgotado = item.qtdAlto == 0;
    return baixoEstoque || esgotado;
  }).length;

  // Formata a data atual
  final String ultimaAtualizacao = 
      'Última atualização: ${DateTime.now().toLocal().toString().substring(0, 16)}';

  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
            },
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
            onPressed: () {
            },
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total de itens cadastrados: $totalItens',
              style: const TextStyle(color: Colors.grey)),
          Text('Total de itens críticos: $itensCriticos',
              style: const TextStyle(color: Colors.grey)),
          Text(ultimaAtualizacao,
              style: const TextStyle(color: Colors.grey)),
        ],
      )
    ],
  );
}
}
