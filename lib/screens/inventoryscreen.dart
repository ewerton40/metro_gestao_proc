import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';

// Um modelo de dados simples para representar um item do inventário.
class InventoryItem {
  final String code;
  final String name;
  final String category;
  final String status;
  final String base;
  final String lastMoved;

  InventoryItem({
    required this.code,
    required this.name,
    required this.category,
    required this.status,
    required this.base,
    required this.lastMoved,
  });
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // --- Variáveis de Estado para os Filtros ---
  String? _selectedStatus;
  String? _selectedCategory;
  String? _selectedBase;
  String? _selectedMovement;
  String _searchText = '';
  
  // --- Listas de Opções para os Dropdowns ---
  final List<String> _statusOptions = ['Todos', 'Em estoque', 'Baixo estoque', 'Esgotado'];
  final List<String> _categoryOptions = ['Todas', 'Spare Parts', 'Ferramentas', 'Equipamento'];
  final List<String> _baseOptions = ['Todas', 'Base Central', 'Base Sul', 'Base Leste', 'Base Oeste'];
  final List<String> _movementOptions = ['Qualquer data', 'Últimos 7 dias', 'Últimos 30 dias'];


  // --- Lista de Dados Fictícios ---
  final List<InventoryItem> _items = [
    InventoryItem(code: 'A0123', name: '', category: 'Spare Parts', status: 'Em estoque', base: 'Base Central', lastMoved: '31.12.2023'),
    InventoryItem(code: '', name: 'Antenna X(b)FC', category: 'Ferramentas', status: 'Baixo estoque', base: 'Base Central', lastMoved: '29.12.2023'),
    InventoryItem(code: '', name: 'Lanterna', category: 'Equipamento', status: 'Baixo estoque', base: 'Base Central', lastMoved: '29.12.2023'),
    InventoryItem(code: '', name: 'Ferraplate', category: 'Equipamento', status: 'Esgotado', base: 'Base Central', lastMoved: '26.12.2023'),
    InventoryItem(code: '', name: 'Pilha', category: 'Equipamento', status: 'Em estoque', base: 'Base Sul', lastMoved: '23.12.2023'),
    InventoryItem(code: '', name: 'Parafusadeira', category: 'Spare Parts', status: 'Em estoque', base: 'Base Leste', lastMoved: '29.02.2023'),
    InventoryItem(code: '', name: 'Baixo Lead', category: 'Ferramentas', status: 'Esgotado', base: 'Base Oeste', lastMoved: '29.02.2023'),
    InventoryItem(code: '', name: 'Chave de fenda', category: 'Ferramentas', status: 'Esgotado', base: 'Base Central', lastMoved: '29.02.2023'),
  ];

  @override
  Widget build(BuildContext context) {
    // Lógica de filtragem encadeada
    List<InventoryItem> filteredItems = _items;

    // Filtros de Dropdown
    if (_selectedStatus != null) {
      filteredItems = filteredItems.where((item) => item.status == _selectedStatus).toList();
    }
    if (_selectedCategory != null) {
      filteredItems = filteredItems.where((item) => item.category == _selectedCategory).toList();
    }
    if (_selectedBase != null) {
      filteredItems = filteredItems.where((item) => item.base == _selectedBase).toList();
    }

    // Filtro da barra de pesquisa
    if (_searchText.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        final searchLower = _searchText.toLowerCase();
        final nameMatches = item.name.toLowerCase().contains(searchLower);
        final codeMatches = item.code.toLowerCase().contains(searchLower);
        return nameMatches || codeMatches;
      }).toList();
    }

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
            Expanded(child: _buildDataTable(filteredItems)),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // Constrói o cabeçalho da área de conteúdo.
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

  // Constrói a barra de pesquisa e os filtros.
  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
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
            // Dropdown Categoria
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedCategory,
                hint: 'Todas',
                items: _categoryOptions,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = (newValue == 'Todas') ? null : newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            
            // Dropdown Status
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedStatus,
                hint: 'Todos',
                items: _statusOptions,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = (newValue == 'Todos') ? null : newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),

            // Dropdown Base Operacional
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedBase,
                hint: 'Todas',
                items: _baseOptions,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBase = (newValue == 'Todas') ? null : newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),

            // Dropdown Última Movimentação
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedMovement,
                hint: 'Qualquer data',
                items: _movementOptions,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMovement = (newValue == 'Qualquer data') ? null : newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget auxiliar para criar os dropdowns de filtro
  Widget _buildFilterDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value ?? hint, // Mostra o hint (ex: 'Todos') se o valor for nulo
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis), // Evita quebra de linha
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }
  
  // Constrói a tabela de dados.
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
            DataColumn(label: Text('Código / Nome do Item')),
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Base Operacional')),
            DataColumn(label: Text('Última Movimentação')),
          ],
          rows: items.map((item) {
            return DataRow(cells: [
              DataCell(Text(item.code.isNotEmpty ? item.code : item.name)),
              DataCell(Text(item.category)),
              DataCell(_getStatusWidget(item.status)),
              DataCell(Text(item.base)),
              DataCell(Text(item.lastMoved)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // Retorna um widget estilizado para o status do item.
  Widget _getStatusWidget(String status) {
    // ... (Sem alterações neste método)
    Color color;
    switch (status) {
      case 'Em estoque':
        color = Colors.green;
        break;
      case 'Baixo estoque':
        color = Colors.orange;
        break;
      case 'Esgotado':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold));
  }

  // Constrói o rodapé com os botões e informações.
  Widget _buildFooter() {
    // ... (Sem alterações neste método)
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