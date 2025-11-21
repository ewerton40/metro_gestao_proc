import 'package:flutter/material.dart';
import 'package:metro_projeto/screens/material_registration_screen.dart';
import '../services/inventory_service.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../utils/models/location.dart';

// ====================================================================
// MODELOS (MANTIDOS INTACTOS)
// ====================================================================

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

  String? _selectedStatus;
  Category? _selectedCategory;
  String _searchText = '';
  List<SimpleLocation> _basesList = [];
  SimpleLocation? _selectedBase;

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
      final results = await Future.wait([
        inventario.getAllItems(baseId: _selectedBase?.id),
        inventario.getAllCategories(),
        inventario.getAllLocations(),
      ]);

      setState(() {
        _items = results[0] as List<InventoryItem>;
        _categories = results[1] as List<Category>;
        _basesList = results[2] as List<SimpleLocation>;

        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        _errorMessage = 'Erro ao carregar dados do servidor.';
        _isLoading = false;
      });
    }
  }


  List<InventoryItem> _applyFilters(List<InventoryItem> items) {
    List<InventoryItem> filtered = items;

    if (_selectedCategory != null) {
      filtered = filtered
          .where((item) => item.categoriaId == _selectedCategory!.id)
          .toList();
    }

    if (_selectedStatus != null && _selectedStatus != 'Todos') {
      filtered = filtered.where((item) {
        if (_selectedStatus == 'Em estoque') {
          return item.quantidadeAtual > item.qtdBaixo;
        } else if (_selectedStatus == 'Baixo estoque') {
          return item.quantidadeAtual <= item.qtdBaixo &&
              item.quantidadeAtual > 0;
        } else if (_selectedStatus == 'Esgotado') {
          return item.quantidadeAtual == 0;
        }
        return true;
      }).toList();
    }

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: const BarMenu(),
      drawer: VerticalMenu(selectedIndex: 1),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            _buildSearchAndFilters(theme),
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
                                    style: theme.textTheme.titleMedium!
                                        .copyWith(color: theme.colorScheme.error)))
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  const double breakpoint = 800.0;
                                  if (constraints.maxWidth < breakpoint) {
                                    return _buildMobileList(filteredItems, theme);
                                  } else {
                                    return _buildDataTable(filteredItems, theme);
                                  }
                                },
                              ),
                  ),
                  const SizedBox(height: 24),
                  _buildFooter(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Text(
      'Inventário',
      style: theme.textTheme.headlineLarge!.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF082583), 
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _searchText = value),
          decoration: InputDecoration(
            hintText: 'Pesquisar item por nome...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return Column(
                children: [
                  _buildCategoryDropdown(theme),
                  const SizedBox(height: 16),
                  _buildBaseDropdown(theme),
                  const SizedBox(height: 16),
                  _buildStatusDropdown(theme),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(child: _buildCategoryDropdown(theme)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildBaseDropdown(theme)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatusDropdown(theme)),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(ThemeData theme, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white, // Fundo branco para os dropdowns
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildBaseDropdown(ThemeData theme) {
    return DropdownButtonFormField<SimpleLocation>(
      value: _selectedBase,
      decoration: _dropdownDecoration(theme, 'Todas as Bases'),
      items: [
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
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return DropdownButtonFormField<Category>(
      value: _selectedCategory,
      decoration: _dropdownDecoration(theme, 'Todas as categorias'),
      items: [
        const DropdownMenuItem<Category>(
          value: null,
          child: Text('Todas as categorias'),
        ),
        ..._categories.map(
          (category) => DropdownMenuItem<Category>(
            value: category,
            child: Text(category.nome),
          ),
        ),
      ],
      onChanged: (newValue) {
        setState(() => _selectedCategory = newValue);
      },
    );
  }

  Widget _buildStatusDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: _dropdownDecoration(theme, 'Status de Estoque'),
      items: _statusOptions
          .map(
            (status) => DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        setState(() => _selectedStatus = newValue);
      },
    );
  }

  Color _getStatusColor(InventoryItem item) {
    if (item.quantidadeAtual == 0) {
      return Colors.red.shade700;
    } else if (item.quantidadeAtual <= item.qtdBaixo) {
      return Colors.orange.shade700;
    } else {
      return Colors.green.shade700;
    }
  }

  String _getStatusText(InventoryItem item) {
    if (item.quantidadeAtual == 0) {
      return 'Esgotado';
    } else if (item.quantidadeAtual <= item.qtdBaixo) {
      return 'Baixo Estoque';
    } else {
      return 'Em Estoque';
    }
  }

  Widget _buildDataTable(List<InventoryItem> items, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 24,
          dataRowMinHeight: 50,
          dataRowMaxHeight: 60,
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade50), // Fundo azul claro para o cabeçalho da tabela
          headingTextStyle: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
          columns: const [
            DataColumn(label: Text('CÓDIGO')),
            DataColumn(label: Text('NOME')),
            DataColumn(label: Text('CATEGORIA')),
            DataColumn(label: Text('QTD. ATUAL'), numeric: true),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('CALIBRAÇÃO')),
          ],
          rows: items.map((item) {
            final statusColor = _getStatusColor(item);
            final statusText = _getStatusText(item);

            return DataRow(
              cells: [
                DataCell(Text(item.code.toString())),
                DataCell(Text(item.nome, style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Text(item.categoriaNome)),
                DataCell(Text('${item.quantidadeAtual}', textAlign: TextAlign.right)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.bodySmall!.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataCell(
                  Icon(
                    item.calibracao ? Icons.check_circle : Icons.cancel,
                    color: item.calibracao ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(List<InventoryItem> items, ThemeData theme) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final statusColor = _getStatusColor(item);
        final statusText = _getStatusText(item);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(item.code.toString(), style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.primary)),
            ),
            title: Text(item.nome, style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Categoria: ${item.categoriaNome}'),
                Text('Qtd. Atual: ${item.quantidadeAtual}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: theme.textTheme.bodySmall!.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                item.calibracao
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                    : const Icon(Icons.cancel, color: Colors.grey, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(ThemeData theme) {
    // Lógica de negócio mantida: cálculo de totais e navegação
    int totalItens = _items.length;
    int itensCriticos = _items.where((item) => item.quantidadeAtual <= item.qtdBaixo).length;
    String ultimaAtualizacao = 'Última atualização: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MaterialRegistrationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Cadastrar Itens'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700, // Usando um azul mais forte para o botão
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Borda mais arredondada
                elevation: 4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFooterStat(
                  'Total de itens cadastrados: $totalItens', theme.colorScheme.onSurface),
              const SizedBox(width: 24),
              _buildFooterStat(
                  'Total de itens críticos: $itensCriticos', theme.colorScheme.error),
              const SizedBox(width: 24),
              _buildFooterStat(ultimaAtualizacao, theme.colorScheme.onSurface.withOpacity(0.7)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFooterStat(String text, Color color) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }
}
