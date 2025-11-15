import 'package:flutter/material.dart';
import 'package:metro_projeto/screens/CadastroMaterialScreen.dart';
import 'package:metro_projeto/screens/detalhe_item_screen.dart';
import '../services/inventory_service.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../utils/models/location.dart';

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
  final int quantidadeAtual;

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
    required this.quantidadeAtual,
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
      quantidadeAtual: int.tryParse(json['qtdAtual'].toString()) ?? 0,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
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
  List<SimpleLocation> _basesList = [];
  SimpleLocation? _selectedBase;
  bool _isLoadingBases = true;

  final List<String> _statusOptions = [
    'Todos',
    'Em estoque',
    'Baixo estoque',
    'Esgotado'
  ];

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
      // Agora buscamos os 3 conjuntos de dados em paralelo
      final results = await Future.wait([
        inventario.getAllItems(baseId: _selectedBase?.id), // Passa o ID da base
        inventario.getAllCategories(),
        inventario
            .getAllLocations(), // Busca as bases (da tela de movimentação)
      ]);

      setState(() {
        _items = results[0] as List<InventoryItem>;
        _categories = results[1] as List<Category>;
        _basesList =
            results[2] as List<SimpleLocation>; // Salva a lista de bases

        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      print('Erro ao carregar dados: $e'); //
      setState(() {
        _errorMessage = 'Erro ao carregar dados do servidor.'; //
        _isLoading = false;
      });
    }
  }

  // Filtros
  List<InventoryItem> _applyFilters(List<InventoryItem> items) {
    List<InventoryItem> filtered = items;

    // Filtro por categoria
    if (_selectedCategory != null) {
      filtered = filtered
          .where((item) => item.categoriaId == _selectedCategory!.id)
          .toList();
    }

    // Filtro por status (estoque)
    if (_selectedStatus != null && _selectedStatus != 'Todos') {
      filtered = filtered.where((item) {
        if (_selectedStatus == 'Em estoque') {
          // Em estoque = A quantidade real é maior que o limite baixo
          return item.quantidadeAtual > item.qtdBaixo;
        } else if (_selectedStatus == 'Baixo estoque') {
          // Baixo estoque = A qtd real está entre 0 e o limite baixo
          return item.quantidadeAtual <= item.qtdBaixo &&
              item.quantidadeAtual > 0;
        } else if (_selectedStatus == 'Esgotado') {
          // Esgotado = A qtd real é 0
          return item.quantidadeAtual == 0;
        }
        return true;
      }).toList();
    }

    // Filtro de busca
    if (_searchText.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.nome.toLowerCase().contains(_searchText.toLowerCase()))
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
      drawer: VerticalMenu(selectedIndex: 1),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchAndFilters(),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage.isNotEmpty
                            ? Center(
                                child: Text(_errorMessage,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 16)))
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  const double breakpoint = 800.0;
                                  if (constraints.maxWidth < breakpoint) {
                                    return _buildMobileList(filteredItems);
                                  } else {
                                    return _buildDataTable(filteredItems);
                                  }
                                },
                              ),
                  ),
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
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
        ), //
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Se a largura for menor que 700 pixels, muda o layout
            if (constraints.maxWidth < 700) {
              return Column(
                children: [
                  _buildCategoryDropdown(), //
                  const SizedBox(height: 16),
                  _buildBaseDropdown(), //
                  const SizedBox(height: 16),
                  _buildStatusDropdown(), //
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: _buildCategoryDropdown(), //
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBaseDropdown(), //
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatusDropdown(), //
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildBaseDropdown() {
    return DropdownButtonFormField<SimpleLocation>(
      value: _selectedBase,
      hint: const Text('Todas as Bases'),
      items: [
        // Adiciona a opção "Todas as Bases" (valor null)
        const DropdownMenuItem<SimpleLocation>(
          value: null,
          child: Text('Todas as Bases'),
        ),
        ..._basesList.map(
          (base) => DropdownMenuItem<SimpleLocation>(
            value: base,
            child: Text(base.nome),
          ),
        ),
      ],
      onChanged: (newValue) {
        setState(() => _selectedBase = newValue);
        _fetchData();
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
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
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Código')),
            DataColumn(label: Text('Nome')),
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Quantidade')),
            DataColumn(label: Text('Medida')),
            DataColumn(label: Text('Status Calibração')),
          ],
          rows: items.map((item) {
            return DataRow(cells: [
              DataCell(Text(item.code.toString())),
              DataCell(Text(item.nome)),
              DataCell(Text(item.categoriaNome)),
              DataCell(Text(item.quantidadeAtual.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(item.medidaNome)),
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

  /// Constrói uma lista de Cards otimizada para celular
  Widget _buildMobileList(List<InventoryItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        Color statusColor;
        if (item.quantidadeAtual == 0) {
          statusColor = Colors.red;
        } else if (item.quantidadeAtual <= item.qtdBaixo) {
          statusColor = Colors.orange;
        } else {
          statusColor = Colors.green;
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      item.calibracao ? Icons.check_circle : Icons.cancel,
                      color: item.calibracao ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Categoria: ${item.categoriaNome}'),
                    const Text('  |  '),
                    Text('Medida: ${item.medidaNome}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Quantidade: ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      item.quantidadeAtual.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    // Cálculos dinâmicos
    int totalItens = _items.length;

    int itensCriticos = _items.where((item) {
      bool baixoEstoque =
          item.quantidadeAtual <= item.qtdBaixo && item.quantidadeAtual > 0;
      bool esgotado = item.quantidadeAtual == 0;
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1763A6),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Visualizar Item'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => const CadastroMaterialScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1763A6),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cadastrar Itens'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total de itens cadastrados: $totalItens',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 24), // Espaçamento
              Text('Total de itens críticos: $itensCriticos',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 24), // Espaçamento
              Text(ultimaAtualizacao,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        )
      ],
    );
  }
}
