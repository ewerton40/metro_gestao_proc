import 'package:flutter/material.dart';

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
  // Lista de dados fictícios para popular a tabela.
  final List<InventoryItem> _items = [
    InventoryItem(code: 'A0123', name: '', category: 'Spare Parts', status: 'Em estoque', base: 'Base Central', lastMoved: '31.12.2023'),
    InventoryItem(code: '', name: 'Antenna X(b)FC', category: 'Ferramentas', status: 'Baixo estoque', base: 'Base Central', lastMoved: '29.12.2023'),
    InventoryItem(code: '', name: 'Lanterna', category: 'Equipamento', status: 'Baixo estoque', base: 'Base Central', lastMoved: '29.12.2023'),
    InventoryItem(code: '', name: 'Ferraplate', category: 'Equipamento', status: 'Esgotado', base: 'Base Central', lastMoved: '26.12.2023'),
    InventoryItem(code: '', name: 'Pilha', category: 'Equipamento', status: 'Em estoque', base: 'Base Sul', lastMoved: '23.12.2023'),
    InventoryItem(code: '', name: 'Parafusadeira', category: 'Base Central', status: 'Em estoque', base: 'Base Leste', lastMoved: '29.02.2023'),
    InventoryItem(code: '', name: 'Baixo Lead', category: 'Base Sul', status: 'Esgotado', base: 'Base Oeste', lastMoved: '29.02.2023'),
    InventoryItem(code: '', name: 'Chave de fenda', category: 'Base Central', status: 'Esgotado', base: 'Base Central', lastMoved: '29.02.2023'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Cor de fundo geral
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearchAndFilters(),
                  const SizedBox(height: 24),
                  Expanded(child: _buildDataTable()),
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Constrói a barra lateral de navegação.
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Substitua pelo seu widget de logo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                const Icon(Icons.train, color: Color(0xFF00387B), size: 40),
                const SizedBox(width: 8),
                Text(
                  'Metrô de\nSão Paulo',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildNavItem(Icons.search, 'Inventário', isSelected: true),
          _buildNavItem(Icons.inventory_2_outlined, 'Entradas'),
          _buildNavItem(Icons.bar_chart_outlined, 'Relatórios'),
          _buildNavItem(Icons.help_outline, 'Ajuda'),
        ],
      ),
    );
  }

  // Widget para um item de navegação na barra lateral.
  Widget _buildNavItem(IconData icon, String title, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE9F2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFF1763A6) : Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1763A6) : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  // Constrói o cabeçalho da área de conteúdo.
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Inventário',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF1763A6),
                child: Text('A', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 8),
              const Text('Ana'),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            ],
          ),
        ),
      ],
    );
  }

  // Constrói a barra de pesquisa e os filtros.
  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
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
            _buildFilterChip('Categoria'),
            const SizedBox(width: 16),
            _buildFilterChip('Status'),
            const SizedBox(width: 16),
            _buildFilterChip('Base Operacional'),
            const SizedBox(width: 16),
            _buildFilterChip('Última Movimentação'),
          ],
        ),
      ],
    );
  }

  // Widget para um chip de filtro.
  Widget _buildFilterChip(String label) {
    return OutlinedButton.icon(
      icon: Text(label),
      label: const Icon(Icons.keyboard_arrow_down, size: 16),
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[700],
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Constrói a tabela de dados.
  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
        columns: const [
          DataColumn(label: Text('Código / Nome do Item')),
          DataColumn(label: Text('Categoria')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Base Operacional')),
          DataColumn(label: Text('Última Movimentação')),
        ],
        rows: _items.map((item) {
          return DataRow(cells: [
            DataCell(Text(item.code.isNotEmpty ? item.code : item.name)),
            DataCell(Text(item.category)),
            DataCell(_getStatusWidget(item.status)),
            DataCell(Text(item.base)),
            DataCell(Text(item.lastMoved)),
          ]);
        }).toList(),
      ),
    );
  }

  // Retorna um widget estilizado para o status do item.
  Widget _getStatusWidget(String status) {
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
