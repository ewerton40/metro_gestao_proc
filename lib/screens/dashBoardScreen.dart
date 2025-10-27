import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; 

// Importações para os widgets reutilizáveis
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // MODIFICADO: Trocado de Colors.white para o cinza de fundo
      backgroundColor: const Color(0xFFF8F9FA), 
      
      appBar: const BarMenu(),
      drawer: const VerticalMenu(),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
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

  // Constrói o cabeçalho do conteúdo
  Widget _buildHeader(BuildContext context) {
    // ... (Sem alterações neste método)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Movimentações Hoje', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const Text('Entradas: 12', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
        const Text('Saídas: 8', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
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
            value: '35',
            change: '+2%',
            changeColor: Colors.red,
            chartPlaceholder: _buildLowStockChart(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            title: 'Total de itens',
            value: '1,245',
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
                  const Text('Top 5 Materiais mais usados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  // Constrói os cards de informação de baixo
  Widget _buildBottomInfoCards(BuildContext context) {
    // ... (Sem alterações neste método)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInfoCard(
            title: 'Movimentações Hoje',
            icon: Icons.sync_alt,
            content: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entradas: 12', style: TextStyle(fontSize: 14)),
                Text('Saídas: 8', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
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
        const SizedBox(width: 24),
        Expanded(
          child: _buildInfoCard(
            title: 'Solicitações Pendentes',
            icon: Icons.pending_actions,
            iconColor: Colors.orange,
            content: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pedido 4452', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Aguardando aprovação', style: TextStyle(fontSize: 14)),
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


  // Gráfico de Barras para "Top 5 Materiais"
  Widget _buildTopMaterialsChart() {
    // ... (Sem alterações neste método)
    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  String text = '';
                  switch (value.toInt()) {
                    case 0: text = 'Steel Rails'; break;
                    case 1: text = 'Copper'; break;
                    case 2: text = 'Steel'; break;
                    case 3: text = 'Rubber'; break;
                    case 4: text = 'Insulation'; break;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 10)),
                  );
                },
                reservedSize: 20,
              ),
            ),
          ),
          barGroups: [
            _buildBarGroup(0, 4),    // Steel Rails
            _buildBarGroup(1, 2.5),  // Copper
            _buildBarGroup(2, 3.5),  // Steel
            _buildBarGroup(3, 5),    // Rubber
            _buildBarGroup(4, 3.8),  // Insulation
          ],
        ),
      ),
    );
  }

  // Método auxiliar para criar um grupo de barras
  BarChartGroupData _buildBarGroup(int x, double y) {
    // ... (Sem alterações neste método)
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF1763A6),
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        )
      ],
    );
  }
}