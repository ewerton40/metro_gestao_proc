import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../services/movimentation_services.dart';
import '../services/inventory_service.dart';



class MovementsToday {
  final int entradas;
  final int saidas;

  MovementsToday({required this.entradas, required this.saidas});

  factory MovementsToday.fromJson(Map<String, dynamic> json) {
    return MovementsToday(
      entradas: json['entradas'] ?? 0,
      saidas: json['saidas'] ?? 0,
    );
  }
}



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  MovementsToday? _movementsToday;
  final movimentationServices = MovimentationServices();
  final inventoryServices = InventoryServices();
  int _lowStockCount = 0;
  int _totalItems = 0;
  List<Map<String, dynamic>> _topfiveMaterials = [];

  @override
  void initState() {
    super.initState();
    _loadMovements();
    _loadLowStockCount();
    _loadTotalItems();
    _loadTopFiveMaterials();
  }

   Future<void> _loadMovements() async {
    try {
      final data = await movimentationServices.getMovementsToday();
      setState(() {
        _movementsToday = data;
      });
    } catch (e) {
      print('Erro ao carregar movimentações: $e');
    }
  }

  Future<void> _loadLowStockCount() async {
  try {
    final count = await inventoryServices.getLowStockCount();
    setState(() {
      _lowStockCount = count;
    });
  } catch (e) {
    print('Erro ao carregar itens de baixo estoque: $e');
  }
}

 Future<void> _loadTotalItems() async {
    try {
      final count = await inventoryServices.getTotalItemsCount();
      setState(() {
        _totalItems = count;
      });
    } catch (e) {
      print('Erro ao carregar total de itens: $e');
    }
  }

  Future<void> _loadTopFiveMaterials() async {
  try {
    final data = await movimentationServices.getTop5Materials();
    setState(() {
      _topfiveMaterials = data;
    });
  } catch (e) {
    print('Erro ao carregar top 5 materiais: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFFF8F9FA), 
      
      appBar: const BarMenu(),
      drawer: const VerticalMenu(),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopStatCards(context),
              const SizedBox(height: 24),
              _buildAlertsAndCharts(context),
              const SizedBox(height: 24),
              _buildBottomInfoCards(context),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // Constrói os cards do topo (Itens com baixo estoque, Total de itens)
  Widget _buildTopStatCards(BuildContext context) {
    // ... (Sem alterações neste método)
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Itens com baixo estoque',
            value: '$_lowStockCount',
            change: '+2%',
            changeColor: Colors.red,
            chartPlaceholder: _buildLowStockChart(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            title: 'Total de itens',
            value: '$_totalItems',
            change: '3%',
            changeColor: Colors.blue.shade800,
            chartPlaceholder: _buildTotalItemsChart(),
          ),
        ),
      ],
    );
  }

  // Constrói os cards do meio (Alertas, Top 5)
  Widget _buildAlertsAndCharts(BuildContext context) {
    // ... (Sem alterações neste método)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            shadowColor: Colors.black12,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alertas recentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    title: Text("Item \"Paulo Pau\" está com estoque baixo"),
                    subtitle: Text("02/01 11:45"),
                  ),
                  ListTile(
                    leading: Icon(Icons.error_outline, color: Colors.red),
                    title: Text("Itens Críticos"),
                    subtitle: Text("Cabo XYZ (Estoque: 2)\nLanterna LED (Estoque: 1)"),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Card(
            elevation: 2,
            shadowColor: Colors.black12,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('5 Materiais mais usados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: _buildTopMaterialsChart(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Constrói os botões de ação centrais
  Widget _buildActionButtons(BuildContext context) {
    // ... (Sem alterações neste método)
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1763A6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Registrar Entrada', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 24),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1763A6),
            side: const BorderSide(color: Color(0xFF1763A6), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Registrar saída', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildBottomInfoCards(BuildContext context) {
  final entradas = _movementsToday?.entradas ?? 0;
  final saidas = _movementsToday?.saidas ?? 0;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Primeiro card - Movimentações Hoje
      Expanded(
        child: _buildInfoCard(
          title: 'Movimentações Hoje',
          icon: Icons.sync_alt,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Entradas: $entradas', style: const TextStyle(fontSize: 14)),
              Text('Saídas: $saidas', style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),

      const SizedBox(width: 24),

      // Segundo card - Itens Críticos
      Expanded(
        child: _buildInfoCard(
          title: 'Itens Críticos',
          icon: Icons.error_outline,
          iconColor: Colors.red,
          content: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cabo XYZ (Estoque: 2)', style: TextStyle(fontSize: 14)),
              Text('Lanterna LED (Estoque: 1)', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    ],
  );
}

  // --- WIDGETS AUXILIARES REUTILIZÁVEIS ---

  // Card de estatística para o topo
  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required Color changeColor,
    required Widget chartPlaceholder,
  }) {
    // ... (Sem alterações neste método)
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    Text(change, style: TextStyle(color: changeColor, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                chartPlaceholder,
              ],
            )
          ],
        ),
      ),
    );
  }

  // Card de informação para a base
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget content,
    Color iconColor = Colors.blue,
  }) {
    // ... (Sem alterações neste método)
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  // --- NOVOS WIDGETS PARA OS GRÁFICOS ---

  // Gráfico de Linha para "Total de Itens"
  Widget _buildTotalItemsChart() {
    // ... (Sem alterações neste método)
    final List<FlSpot> spots = [
      FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.4), FlSpot(3, 3.4),
      FlSpot(4, 2), FlSpot(5, 2.2), FlSpot(6, 3.0),
    ];

    return SizedBox(
      width: 100,
      height: 40,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0, maxX: 6, minY: 0, maxY: 4,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue.shade800,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  // Gráfico de Linha para "Itens com baixo estoque"
  Widget _buildLowStockChart() {
    // ... (Sem alterações neste método)
     final List<FlSpot> spots = [
      FlSpot(0, 2), FlSpot(1, 1), FlSpot(2, 2.8), FlSpot(3, 1.5),
      FlSpot(4, 2.2), FlSpot(5, 1.8), FlSpot(6, 3),
    ];

    return SizedBox(
      width: 100,
      height: 40,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0, maxX: 6, minY: 0, maxY: 4,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }


  


  BarChartGroupData _buildBarGroup(int x, double y) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        width: 20,
        // não defina cortica globalmente se não quiser
        color: const Color(0xFF1763A6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
    ],
  );
}


Widget _buildTopMaterialsChart() {

  if (_topfiveMaterials.isEmpty) {
    return const Center(child: CircularProgressIndicator()) ;
    
  }
  
  final List<double> totals = _topfiveMaterials.map<double>((e) {
    final v = e['total_saidas'];
    if (v is int) return v.toDouble();
    if (v is double) return v;
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }).toList();

  // calcula maxY para ajustar o eixo y
  final double maxY = (totals.isNotEmpty ? totals.reduce((a, b) => a > b ? a : b) : 1.0) * 1.2;

  // cria os grupos usando o helper
  final List<BarChartGroupData> barGroups = [];
  for (int i = 0; i < _topfiveMaterials.length; i++) {
    final double value = totals[i];
    barGroups.add(_buildBarGroup(i, value));
  }

  return SizedBox(
    height: 150,
    child: BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int idx = value.toInt();
                if (idx < 0 || idx >= _topfiveMaterials.length) return const SizedBox.shrink();

                final nome = _topfiveMaterials[idx]['material']?.toString() ?? '';
                return SideTitleWidget(
                  meta: meta,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 60),
                    child: Text(
                      nome,
                      style: TextStyle(color: Colors.grey[700], fontSize: 10),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: barGroups,
        alignment: BarChartAlignment.spaceAround,
        groupsSpace: 12,
      ),
    ),
  );
}
}