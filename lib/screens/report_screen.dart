import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../services/report_service.dart';
import '../services/inventory_service.dart';


const Color primaryBlue = Color(0xFF001789); 
const Color lightBlue = Color(0xFF42A5F5); 
const Color whiteBackground = Colors.white; 

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

  Future<void> _generateMovimentacoesReport() async {
    _resetReportState('Relatório de Movimentações');

    try {

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
        
        final color = item['tipo'] == 'entrada' ? Colors.green : Colors.red;

        return DataRow(cells: [
          DataCell(Text(DateTime.parse(item['data'] + 'Z')
              .toLocal()
              .toString()
              .substring(0, 16))),
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
            style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue), 
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
      drawer: VerticalMenu(selectedIndex: 3),
      backgroundColor: whiteBackground, 
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [                  
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double desktopBreakpoint = 700.0;

                  if (constraints.maxWidth < desktopBreakpoint) {
                    // Se a tela for estreita, retorna uma Coluna
                    return _buildMobileLayout();
                  } else {
                    // Se a tela for larga, retorna a Linha
                    return _buildDesktopLayout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
 
        Expanded(
          flex: 2, 
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color.fromARGB(148, 0, 80, 145)), 
                headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                columns: const <DataColumn>[
                  DataColumn(
                      label: Text('Relatório')),
                  DataColumn(
                      label: Text('Descrição')),
                  DataColumn(
                      label: Text('Gerar')),
                ],
                rows: <DataRow>[
                  _buildDataRow(
                      'Movimentações',
                      'Entradas, saídas e transferências',
                      _generateMovimentacoesReport),
                  _buildDataRow('Itens Críticos', 'Materiais com baixo estoque',
                      _generateCriticalItemsReport),
                  _buildDataRow('Consumo', 'Materiais mais utilizados',
                      _generateConsumoReport),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 16), 

        Expanded(
          flex: 3, 
          child: _isLoadingReport
              ? const Center(child: CircularProgressIndicator(color: primaryBlue)) 
              : (_reportRows.isNotEmpty
                  ? _buildResultsTable()
                  : _buildPlaceholderResults()),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(lightBlue), 
              headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              columns: const <DataColumn>[
                DataColumn(label: Text('Relatório')),
                DataColumn(label: Text('Gerar')),
              ],
              rows: <DataRow>[
                _buildDataRow(
                  'Movimentações',
                  '', 
                  _generateMovimentacoesReport,
                ),
                _buildDataRow(
                  'Itens Críticos',
                  '',
                  _generateCriticalItemsReport,
                ),
                _buildDataRow(
                    'Consumo',
                    '', 
                    _generateConsumoReport),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16), 

        Expanded(
          
          child: _isLoadingReport
              ? const Center(child: CircularProgressIndicator(color: primaryBlue)) 
              : (_reportRows.isNotEmpty
                  ? _buildResultsTable()
                  : _buildPlaceholderResults()),
        ),
      ],
    );
  }

  Widget _buildPlaceholderResults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryBlue.withOpacity(0.3)), 
      ),
      child: const Center(
        child: Text(
          'Selecione um relatório para gerar.',
          style: TextStyle(color: primaryBlue, fontSize: 16), 
        ),
      ),
    );
  }

  DataRow _buildDataRow(
      String relatorio, String descricao, VoidCallback onGerarPressed) {
   
    final bool showDescription = descricao.isNotEmpty;

    return DataRow(
      cells: <DataCell>[
        DataCell(Text(relatorio)),

      
        if (showDescription) DataCell(Text(descricao)),

        DataCell(
          ElevatedButton(
            onPressed: onGerarPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            child: const Text('Gerar'),
          ),
        ),
      ],
    );
  }

  
  void _resetReportState(String title) {
    setState(() {
      _isLoadingReport = true;
      _reportColumns = [];
      _reportRows = [];
      _currentReportTitle = title;
    });
  }


  Future<void> _generateCriticalItemsReport() async {
    _resetReportState('Relatório de Itens Críticos');

    try {
   
      final results = await _inventoryService.getCriticalItems();

      final columns = const <DataColumn>[
        DataColumn(label: Text('Material')),
        DataColumn(label: Text('Qtd. Atual')),
        DataColumn(label: Text('Limite Baixo')),
      ];

  
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


  Widget _buildResultsTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryBlue.withOpacity(0.3)), 
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _currentReportTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue), 
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(lightBlue), 
                  headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  columns: _reportColumns,
                  rows: _reportRows,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
