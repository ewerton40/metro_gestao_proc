import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:metro_projeto/screens/charts_per_base_screen.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../services/movimentation_services.dart';
import '../services/inventory_service.dart';

const kPrimaryColor = Color(0xFF007BFF); 
const kWarningColor = Color(0xFFFFC107); 
const kSuccessColor = Color(0xFF28A745);
const kDangerColor = Color(0xFFDC3545);
const kBackgroundColor = Color(0xFFF4F7F9); 
const kCardColor = Colors.white;
const kTextColor = Color(0xFF343A40);

class MovementsToday {
  final int entradas;
  final int saidas;

  MovementsToday({required this.entradas, required this.saidas});

  factory MovementsToday.fromJson(Map<String, dynamic> json) {
    return MovementsToday(
      entradas: json['entradas'],
      saidas: json['saidas'],
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
  List<Map<String, dynamic>> _criticalItems = [];
  List<Map<String, dynamic>> _categoryDistribution = [];

  int _touchedCategoryIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        movimentationServices.getMovementsToday(),
        inventoryServices.getLowStockCount(),
        inventoryServices.getTotalItemsCount(),
        movimentationServices.getTop5Materials(),
        inventoryServices.getCriticalItems(),
        inventoryServices.getMaterialsDistributionByCategory(),
      ]);

      setState(() {
        _movementsToday = results[0] as MovementsToday?;
        _lowStockCount = results[1] as int;
        _totalItems = results[2] as int;
        _topfiveMaterials = results[3] as List<Map<String, dynamic>>;
        _criticalItems = results[4] as List<Map<String, dynamic>>;
        _categoryDistribution = results[5] as List<Map<String, dynamic>>;
      });
    } catch (e) {
      print("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: const BarMenu(),
      drawer: const VerticalMenu(selectedIndex: 0),
      
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Consideramos mobile se a largura for menor que 900px (para caber os gráficos)
          bool isMobile = constraints.maxWidth < 900;
          
          // Ajusta padding para mobile
          double padding = isMobile ? 16.0 : 32.0;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os cards
                children: [

                  // Passamos 'isMobile' para os widgets adaptarem o layout
                  _buildTopStatCards(context, isMobile),
                  const SizedBox(height: 24),

                  _buildBottomInfoCards(context, isMobile),
                  const SizedBox(height: 24),

                  _buildAlertsAndCharts(context, isMobile),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }



  Widget _buildTopStatCards(BuildContext context, bool isMobile) {
    final card1 = _buildStatCard(
      title: 'Itens com baixo estoque',
      value: '$_lowStockCount',
      change: '+2%',
      changeColor: kDangerColor,
      color: kDangerColor,
      icon: Icons.warning_amber_rounded,
    );

    final card2 = _buildStatCard(
      title: 'Total de itens',
      value: '$_totalItems',
      change: '3%',
      changeColor: kPrimaryColor,
      color: kPrimaryColor,
      icon: Icons.inventory_2_outlined,
    );

    if (isMobile) {
      return Column(
        children: [
          card1,
          const SizedBox(height: 16),
          card2,
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 24),
          Expanded(child: card2),
        ],
      );
    }
  }

  Widget _buildBottomInfoCards(BuildContext context, bool isMobile) {
    final card1 = _buildMovementCard(
      title: 'Entradas Hoje',
      value: _movementsToday?.entradas.toString() ?? '...',
      color: kSuccessColor,
      icon: Icons.arrow_downward_rounded,
    );

    final card2 = _buildMovementCard(
      title: 'Saídas Hoje',
      value: _movementsToday?.saidas.toString() ?? '...',
      color: kDangerColor,
      icon: Icons.arrow_upward_rounded,
    );

    if (isMobile) {
      return Column(
        children: [
          card1,
          const SizedBox(height: 16),
          card2,
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 24),
          Expanded(child: card2),
        ],
      );
    }
  }

  Widget _buildAlertsAndCharts(BuildContext context, bool isMobile) {
    final alertsWidget = _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alertas recentes',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor)),
          const SizedBox(height: 16),
          if (_criticalItems.isEmpty)
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle_outline,
                  color: kSuccessColor, size: 30),
              title: Text("Nenhum item com estoque crítico",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text("Tudo certo!"),
            )
          else
            ..._criticalItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.warning_amber_rounded,
                      color: kWarningColor, size: 30),
                  title: Text(
                      "Item \"${item['nome_material']}\" está com estoque baixo",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text("Estoque atual: ${item['quantidade']}"),
                ),
              );
            }),
        ],
      ),
    );

    // Gráfico de Barras (Top 5)
    final barChartWidget = _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top 5 Materiais mais usados',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor)),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: isMobile ? 1.2 : 1.5, // Um pouco mais alto no mobile
            child: _buildTopMaterialsChart(),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChartsByBaseScreen()));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimaryColor,
                side: const BorderSide(color: kPrimaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Ver mais', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    // Gráfico de Pizza (Categorias)
    final pieChartWidget = _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribuição por Categorias',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor)),
          const SizedBox(height: 16),
          isMobile
              ? _buildCategoryDistributionChart(isMobile)
              : AspectRatio(
                  aspectRatio: 1.5,
                  child: _buildCategoryDistributionChart(isMobile),
                ),
          
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const ChartsByBaseScreen()));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimaryColor,
                side: const BorderSide(color: kPrimaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Ver mais', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        alertsWidget,
        const SizedBox(height: 24),
        
        if (isMobile) ...[
          // Mobile: Um embaixo do outro
          barChartWidget,
          const SizedBox(height: 24),
          pieChartWidget,
        ] else ...[
          // Desktop: Lado a lado
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: barChartWidget),
              const SizedBox(width: 24),
              Expanded(child: pieChartWidget),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildCategoryDistributionChart(bool isMobile) {
    if (_categoryDistribution.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalGeral = _categoryDistribution.fold<int>(
        0, (sum, item) => sum + ((item['total'] ?? 0) as int));

    final colors = [
      kPrimaryColor,
      const Color(0xFF17A2B8),
      kWarningColor,
      const Color(0xFF6C757D),
      const Color(0xFF20C997),
    ];
    
    // O gráfico em si
    final pieChart = PieChart(
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
        sectionsSpace: 4,
        centerSpaceRadius: isMobile ? 40 : 60, // Menor no mobile
        sections: List.generate(_categoryDistribution.length, (i) {
          final total = ((_categoryDistribution[i]['total'] ?? 0) as int);
          final percent = (total / totalGeral) * 100;
          final isTouched = _touchedCategoryIndex == i;

          return PieChartSectionData(
            value: total.toDouble(),
            title: '${percent.toStringAsFixed(1)}%',
            color: colors[i % colors.length],
            radius: isTouched ? (isMobile ? 60 : 80) : (isMobile ? 50 : 70),
            titleStyle: TextStyle(
              fontSize: isTouched ? 16 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black45, blurRadius: 3)],
            ),
          );
        }),
      ),
    );

    // A legenda
    final legend = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_categoryDistribution.length, (i) {
        final categoria =
            _categoryDistribution[i]['categoria']?.toString() ?? 'Sem categoria';
        final total = _categoryDistribution[i]['total'];
        final totalStr = (total != null) ? total.toString() : '0';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: _buildCategoryLegendItem(
            colors[i % colors.length],
            categoria,
            totalStr,
            i,
          ),
        );
      }),
    );

    if (isMobile) {
      // Mobile: Gráfico em cima, Legenda embaixo
      return Column(
        children: [
          SizedBox(
            height: 250, // Altura fixa para o gráfico no mobile
            child: pieChart,
          ),
          const SizedBox(height: 24),
          legend,
        ],
      );
    } else {
      // Desktop: Lado a lado
      return Row(
        children: [
          Expanded(
            flex: 4,
            child: pieChart,
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: legend,
          ),
        ],
      );
    }
  }


  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required Color changeColor,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( // Evita overflow do texto
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: kTextColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                change,
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'último mês',
                style: TextStyle(
                  color: kTextColor.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovementCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: kTextColor.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: kCardColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }

  Widget _buildTopMaterialsChart() {
    if (_topfiveMaterials.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<double> totals = _topfiveMaterials.map<double>((e) {
      final v = e['total_saidas'] ?? e['total_usado'] ?? 0;
      if (v is int) return v.toDouble();
      if (v is double) return v;
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }).toList();

    final double maxVal =
        totals.isEmpty ? 0 : totals.reduce((a, b) => a > b ? a : b);
    double maxY;
    if (maxVal == 0) {
      maxY = 10.0;
    } else {
      maxY = (maxVal * 1.2).ceilToDouble();
      if (maxY < 5) {
        maxY = 5.0;
      }
    }
    double calculatedInterval = maxY / 4;
    double interval = calculatedInterval.ceilToDouble();
    if (interval == 0) {
      interval = 1.0;
    }

    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < _topfiveMaterials.length; i++) {
      final double value = totals[i];
      barGroups.add(_buildBarGroup(i, value, color: kPrimaryColor));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            left: BorderSide(color: Colors.grey.shade300, width: 1),
            right: BorderSide.none,
            top: BorderSide.none,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style:
                    TextStyle(fontSize: 10, color: kTextColor.withOpacity(0.7)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int idx = value.toInt();
                if (idx < 0 || idx >= _topfiveMaterials.length) {
                  return const SizedBox.shrink();
                }
                final nome =
                    _topfiveMaterials[idx]['material']?.toString() ?? '';
                return SideTitleWidget(
                  meta: meta,
                  space: 8.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 60),
                    child: Text(
                      nome,
                      style: TextStyle(
                          color: kTextColor.withOpacity(0.8), fontSize: 10),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => kPrimaryColor.withOpacity(0.9),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final nome = _topfiveMaterials[groupIndex]['material'] ??
                  'Desconhecido';
              return BarTooltipItem(
                '$nome\n${rod.toY.toInt()} movimentações',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y,
      {Color color = kPrimaryColor}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 16,
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.6),
              color,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryLegendItem(
      Color color, String label, String value, int index) {
    final isActive = _touchedCategoryIndex == index;
    return Row(
      children: [
        Container(
          width: isActive ? 16 : 14,
          height: isActive ? 16 : 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isActive
                ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)]
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isActive ? 14 : 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? kTextColor : kTextColor.withOpacity(0.8),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isActive ? 14 : 13,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
      ],
    );
  }
}