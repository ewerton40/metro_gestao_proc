import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _touchedCategoryIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ADICIONEI DE VOLTA: A cor de fundo e a AppBar/Drawer para manter o layout
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const BarMenu(),
      drawer: const VerticalMenu(),
      body: SingleChildScrollView(
        // ADICIONEI DE VOLTA: Padding para o conteúdo
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CORREÇÃO: Chamei os métodos que você colou, em vez da classe 'DashboardCharts'
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

  //
  // --- MÉTODOS MOVIDOS PARA DENTRO DA CLASSE ---
  //

  // Cards superiores
  Widget _buildTopStatCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildStatCard(
            title: 'Itens com baixo estoque',
            value: '35',
            change: '+2%',
            changeColor: Colors.red,
            chartPlaceholder: _buildLowStockPieChart(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Card(
            elevation: 3,
            shadowColor: Colors.black26,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total de itens',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1,245',
                              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                          Text('3%',
                              style: TextStyle(
                                  color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Alerta + gráfico de top 5
  Widget _buildAlertsAndCharts(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                elevation: 3,
                shadowColor: Colors.black26,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alertas recentes',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.warning_amber_rounded,
                            color: Colors.orange),
                        title: Text(
                            "Item \"Paulo Pau\" está com estoque baixo"),
                        subtitle: Text("02/01 11:45"),
                      ),
                      ListTile(
                        leading: Icon(Icons.error_outline, color: Colors.red),
                        title: Text("Itens Críticos"),
                        subtitle: Text(
                            "Cabo XYZ (Estoque: 2)\nLanterna LED (Estoque: 1)"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                elevation: 3,
                shadowColor: Colors.black26,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Top 5 Materiais mais usados',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: _buildTopMaterialsChart(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Card(
                elevation: 3,
                shadowColor: Colors.black26,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Distribuição por Categorias',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: _buildCategoryDistributionChart(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Cards de estatística
  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required Color changeColor,
    required Widget chartPlaceholder,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 34, fontWeight: FontWeight.bold)),
                    Text(change,
                        style: TextStyle(
                            color: changeColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                chartPlaceholder,
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🥧 Gráfico: Itens com baixo estoque (pizza com legenda)
  Widget _buildLowStockPieChart() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 25,
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: '35',
                    color: Colors.red.shade600,
                    radius: 35,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20',
                    color: Colors.orange.shade500,
                    radius: 30,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 15,
                    title: '15',
                    color: Colors.amber.shade400,
                    radius: 28,
                    titleStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Legenda
          Wrap(
            spacing: 8,
            children: [
              _buildLegendItem(Colors.red.shade600, 'Crítico'),
              _buildLegendItem(Colors.orange.shade500, 'Baixo'),
              _buildLegendItem(Colors.amber.shade400, 'Alerta'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
      ],
    );
  }

  // 📊 Gráfico: Top 5 Materiais mais usados (com linhas de grade)
  Widget _buildTopMaterialsChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey[300]!),
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        maxY: 6,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipColor: (group) => Colors.blueGrey[800]!,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String label = '';
              switch (group.x.toInt()) {
                case 0:
                  label = 'Steel Rails';
                  break;
                case 1:
                  label = 'Copper';
                  break;
                case 2:
                  label = 'Steel';
                  break;
                case 3:
                  label = 'Rubber';
                  break;
                case 4:
                  label = 'Insulation';
                  break;
              }
              return BarTooltipItem(
                '$label\n',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: '${rod.toY.toInt()} unidades',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {},
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                String text = '';
                switch (value.toInt()) {
                  case 0:
                    text = 'Steel\nRails';
                    break;
                  case 1:
                    text = 'Copper';
                    break;
                  case 2:
                    text = 'Steel';
                    break;
                  case 3:
                    text = 'Rubber';
                    break;
                  case 4:
                    text = 'Install.';
                    break;
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
        ),
        barGroups: [
          _buildBarGroup(0, 4),
          _buildBarGroup(1, 2.5),
          _buildBarGroup(2, 3.5),
          _buildBarGroup(3, 5),
          _buildBarGroup(4, 3.8),
        ],
      ),
    );
  }

  // CORREÇÃO: Adicionei este método auxiliar que estava faltando
  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1763A6).withOpacity(0.8),
              const Color(0xFF4A90E2),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 22,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        )
      ],
    );
  }

  Widget _buildCategoryDistributionChart() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedCategoryIndex = -1;
                      return;
                    }
                    _touchedCategoryIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(
                  value: 280,
                  title: '280',
                  color: const Color(0xFF1763A6),
                  radius: _touchedCategoryIndex == 0 ? 75 : 65,
                  titleStyle: TextStyle(
                    fontSize: _touchedCategoryIndex == 0 ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: 195,
                  title: '195',
                  color: const Color(0xFF4A90E2),
                  radius: _touchedCategoryIndex == 1 ? 70 : 60,
                  titleStyle: TextStyle(
                    fontSize: _touchedCategoryIndex == 1 ? 15 : 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: 165,
                  title: '165',
                  color: const Color(0xFF7AB8F5),
                  radius: _touchedCategoryIndex == 2 ? 67 : 57,
                  titleStyle: TextStyle(
                    fontSize: _touchedCategoryIndex == 2 ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: 140,
                  title: '140',
                  color: const Color(0xFFA5D0F9),
                  radius: _touchedCategoryIndex == 3 ? 65 : 55,
                  titleStyle: TextStyle(
                    fontSize: _touchedCategoryIndex == 3 ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: 465,
                  title: '465',
                  color: Colors.grey.shade400,
                  radius: _touchedCategoryIndex == 4 ? 63 : 53,
                  titleStyle: TextStyle(
                    fontSize: _touchedCategoryIndex == 4 ? 13 : 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryLegendItem(
                  const Color(0xFF1763A6), 'Elétricos', '280', 0),
              const SizedBox(height: 8),
              _buildCategoryLegendItem(
                  const Color(0xFF4A90E2), 'Mecânicos', '195', 1),
              const SizedBox(height: 8),
              _buildCategoryLegendItem(
                  const Color(0xFF7AB8F5), 'Estruturais', '165', 2),
              const SizedBox(height: 8),
              _buildCategoryLegendItem(
                  const Color(0xFFA5D0F9), 'Hidráulicos', '140', 3),
              const SizedBox(height: 8),
              _buildCategoryLegendItem(
                  Colors.grey.shade400, 'Outros', '465', 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryLegendItem(Color color, String label, String value, int index) {
    final isActive = _touchedCategoryIndex == index;
    return Row(
      children: [
        Container(
          width: isActive ? 14 : 12,
          height: isActive ? 14 : 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: isActive
                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)]
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isActive ? 13 : 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? Colors.grey[900] : Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isActive ? 13 : 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.grey[900] : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  // Outros componentes (cards e botões) permanecem os mesmos
  Widget _buildBottomInfoCards(BuildContext context) => const SizedBox.shrink();
  Widget _buildActionButtons(BuildContext context) => const SizedBox.shrink();
}