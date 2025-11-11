// Em: lib/screens/reportscreen.dart
import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../services/report_service.dart';
import '../services/inventory_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _reportService = ReportService();
  final _inventoryService = InventoryServices();

  bool _isLoadingReport = false;
  String _currentReportTitle = '';

  List<DataColumn> _reportColumns = [];
  List<DataRow> _reportRows = [];

  /// Gera o Relatório de Movimentações

  Future<void> _generateMovimentacoesReport() async {
    _resetReportState('Relatório de Movimentações');

    try {
      // Chama o novo serviço
      final results = await _reportService.fetchMovimentacoes();

      final columns = const <DataColumn>[
        DataColumn(label: Text('Data')),
        DataColumn(label: Text('Material')),
        DataColumn(label: Text('Qtd')),
        DataColumn(label: Text('Tipo')),
        DataColumn(label: Text('Funcionário')),
        DataColumn(label: Text('Origem')),
        DataColumn(label: Text('Destino')),
      ];

      final rows = results.map((item) {
        // Colore a linha de 'entrada' ou 'saida'
        final color = item['tipo'] == 'entrada' ? Colors.green : Colors.red;

        return DataRow(cells: [
          DataCell(Text(DateTime.parse(item['data'] + 'Z').toLocal().toString().substring(0, 16))),
          DataCell(Text(item['material'])),
          DataCell(Text(item['quantidade'].toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold))),
          DataCell(Text(item['tipo'])),
          DataCell(Text(item['funcionario'])),
          DataCell(Text(item['origem'])),
          DataCell(Text(item['destino'])),
        ]);
      }).toList();

      setState(() {
        _reportColumns = columns;
        _reportRows = rows;
        _isLoadingReport = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReport = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao gerar relatório: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  //Gera o relatório de consumo
  Future<void> _generateConsumoReport() async {
    _resetReportState('Relatório de Consumo (Top 10)');

    try {
      final results = await _reportService.fetchConsumo();

      final columns = const <DataColumn>[
        DataColumn(label: Text('Material')),
        DataColumn(label: Text('Total Consumido (Qtd)')),
      ];

      final rows = results.map((item) {
        return DataRow(cells: [
          DataCell(Text(item['nome_material'])),
          DataCell(Text(
            item['total_consumido'].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
        ]);
      }).toList();

      setState(() {
        _reportColumns = columns;
        _reportRows = rows;
        _isLoadingReport = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReport = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao gerar relatório: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarMenu(),
      drawer: const VerticalMenu(selectedIndex: 3),
      backgroundColor: const Color(0xFFF7F8F9),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          // Coluna principal (vertical)
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PARTE 1: CABEÇALHO (Fica no topo, como antes) ---
            const Text(
              'Relatórios',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // ... (Sua Row de Pesquisa vai aqui)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Pesquisar',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ... (Sua Row de Filtros vai aqui)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      label: Text('Categoria'),
                    ),
                    items: ['Todas']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      label: Text('Tipo'),
                    ),
                    items: ['Todas']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      label: Text('Período'),
                    ),
                    items: ['Últimos 30 dias']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      label: Text('Formato'),
                    ),
                    items: ['PDF']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // --- FIM DO CABEÇALHO ---

            // --- PARTE 2: NOVA ROW PARA AS TABELAS (Lado a Lado) ---
            Expanded(
              // Faz a Row preencher o resto do espaço vertical
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Coluna da Esquerda (Opções) ---
                  Expanded(
                    flex: 2, // Ocupa 2/5 (40%) do espaço
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                              label: Text('Relatório',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Descrição',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Gerar',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: <DataRow>[
                          _buildDataRow(
                            'Movimentações',
                            'Entradas, saídas e transferências',
                            _generateMovimentacoesReport,
                          ),
                          _buildDataRow(
                            'Itens Críticos',
                            'Materiais com baixo estoque',
                            _generateCriticalItemsReport,
                          ),
                          _buildDataRow(
                            'Consumo',
                            'Materiais mais utilizados',
                            _generateConsumoReport, 
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16), // Divisor

                  // --- Coluna da Direita (Resultados) ---
                  Expanded(
                    flex: 3, // Ocupa 3/5 (60%) do espaço
                    child: _isLoadingReport
                        ? const Center(child: CircularProgressIndicator())
                        : (_reportRows.isNotEmpty
                            ? _buildResultsTable() // O widget com scroll horizontal
                            : _buildPlaceholderResults() // Placeholder
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Adicione este novo widget de placeholder
  Widget _buildPlaceholderResults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Text(
          'Selecione um relatório para gerar.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
    );
  }

  // Definição do _buildDataRow
  DataRow _buildDataRow(
      String relatorio, String descricao, VoidCallback onGerarPressed) {
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(relatorio)),
        DataCell(Text(descricao)),
        DataCell(
          ElevatedButton(
            onPressed: onGerarPressed,
            child: const Text('Gerar'),
          ),
        ),
      ],
    );
  }

  /// Limpa os resultados e define o estado de loading
  void _resetReportState(String title) {
    setState(() {
      _isLoadingReport = true;
      _reportColumns = [];
      _reportRows = [];
      _currentReportTitle = title;
    });
  }

  /// Gera o Relatório de Itens Críticos
  Future<void> _generateCriticalItemsReport() async {
    _resetReportState('Relatório de Itens Críticos');

    try {
      // Usa o inventory_service que já existia
      final results = await _inventoryService.getCriticalItems();

      // Define as colunas para este relatório
      final columns = const <DataColumn>[
        DataColumn(label: Text('Material')),
        DataColumn(label: Text('Qtd. Atual')),
        DataColumn(label: Text('Limite Baixo')),
      ];

      // Define as linhas para este relatório
      final rows = results.map((item) {
        return DataRow(cells: [
          DataCell(Text(item['nome_material'])),
          DataCell(Text(
            item['quantidade'].toString(),
            style:
                const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          )),
          DataCell(Text(item['limite_baixo'].toString())),
        ]);
      }).toList();

      setState(() {
        _reportColumns = columns;
        _reportRows = rows;
        _isLoadingReport = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReport = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao gerar relatório: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  /// Widget da Tabela de Resultados
  Widget _buildResultsTable() {
    return Container(
      width: double
          .infinity, // Garante que o container preencha o espaço horizontal
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _currentReportTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                columns: _reportColumns,
                rows: _reportRows,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
