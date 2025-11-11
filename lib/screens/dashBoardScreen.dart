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
  

  // Variável para o gráfico de Distribuição por Categorias
  int _touchedCategoryIndex = -1;
  // Variável para o gráfico de Itens com Baixo Estoque (NOVA)
  int _touchedLowStockIndex = -1;


  @override
  void initState() {
    super.initState();
    _loadMovements();
    _loadLowStockCount();
    _loadTotalItems();
    _loadTopFiveMaterials();
    _loadCriticalItems();
    _loadCategoryDistribution();
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

  Future<void> _loadCriticalItems() async {
    try {
      final items = await InventoryServices().getCriticalItems();
      setState(() {
        _criticalItems = items;
      });
    } catch (e) {
      print('Erro ao carregar itens críticos: $e');
    }
  }

  Future<void> _loadCategoryDistribution() async {
    try {
      final data = await inventoryServices.getMaterialsDistributionByCategory();
      setState(() {
        _categoryDistribution = data;
      });
    } catch (e) {
      print('Erro ao carregar distribuição por categoria: $e');
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

  // --- MÉTODOS DE CONSTRUÇÃO DE SEÇÃO ---

  /// Constrói os cards do topo (Itens com baixo estoque, Total de itens)
  /// USA DADOS: _lowStockCount, _totalItems
  Widget _buildTopStatCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildStatCard(
            title: 'Itens com baixo estoque',
            value: '$_lowStockCount', // DADO REAL
            change: '+2%', // Placeholder
            changeColor: Colors.red,
            chartPlaceholder: _buildLowStockPieChart(), // GRÁFICO AGORA DINÂMICO
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            title: 'Total de itens',
            value: '$_totalItems', // DADO REAL
            change: '3%', // Placeholder
            changeColor: Colors.blue.shade800,
            chartPlaceholder: _buildTotalItemsChart(),
          ),
        ),
      ],
    );
  }

  /// Constrói os cards do meio (Alertas, Top 5, Categorias)
  /// USA DADOS: _criticalItems, _topfiveMaterials
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Alertas recentes',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (_criticalItems.isEmpty)
                        const ListTile(
                          leading: Icon(Icons.check_circle_outline,
                              color: Colors.green),
                          title: Text("Nenhum item com estoque crítico"),
                          subtitle: Text("Tudo certo!"),
                        )
                      else
                        ..._criticalItems.map((item) {
                          return ListTile(
                            leading: const Icon(Icons.warning_amber_rounded,
                                color: Colors.orange),
                            title: Text(
                                "Item \"${item['nome_material']}\" está com estoque baixo"),
                            subtitle:
                                Text("Estoque atual: ${item['quantidade']}"),
                          );
                        }).toList(),
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
                        child: _buildTopMaterialsChart(), // DADO REAL
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
                        child:
                            _buildCategoryDistributionChart(), // PLACEHOLDER (Estático e Dinâmico)
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

  /// Constrói os cards inferiores (Movimentações, Itens Críticos)
  /// USA DADOS: _movementsToday, _criticalItems
  Widget _buildBottomInfoCards(BuildContext context) {
    final entradas = _movementsToday?.entradas ?? 0;
    final saidas = _movementsToday?.saidas ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInfoCard(
            title: 'Movimentações Hoje',
            icon: Icons.sync_alt,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entradas: $entradas',
                    style: const TextStyle(fontSize: 14)), // DADO REAL
                Text('Saídas: $saidas',
                    style: const TextStyle(fontSize: 14)), // DADO REAL
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
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _criticalItems.isEmpty
                  ? [const Text('Nenhum item crítico no momento.')]
                  : _criticalItems.map((item) {
                      // DADO REAL
                      return Text(
                        '${item['nome_material']} (Estoque: ${item['quantidade']})',
                        style: const TextStyle(fontSize: 14),
                      );
                    }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) =>
      const SizedBox.shrink(); // Mantido como placeholder

  // --- WIDGETS AUXILIARES REUTILIZÁVEIS ---

  /// Card de estatística para o topo
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

  /// Card de informação genérico (usado na fileira de baixo)
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget content,
    Color iconColor = Colors.blue,
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
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  // --- GRÁFICOS ---

  /// 🥧 Gráfico: Itens com baixo estoque (PLACEHOLDER FUNCIONAL COM LEGENDA e INTERATIVIDADE)
  Widget _buildLowStockPieChart() {
    // Dados de placeholder (Crítico, Baixo, Alerta)
    final sectionsData = [35.0, 20.0, 15.0];
    final sectionsColors = [
      Colors.red.shade600,
      Colors.orange.shade500,
      Colors.amber.shade400
    ];
    final sectionsLabels = ['Crítico', 'Baixo', 'Alerta'];

    return SizedBox(
      width: 140,
      height: 140,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                // ADICIONANDO A FUNCIONALIDADE DE TOQUE (Dinamismo)
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedLowStockIndex = -1;
                        return;
                      }
                      _touchedLowStockIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 3,
                centerSpaceRadius: 25,
                sections: List.generate(sectionsData.length, (i) {
                  final isTouched = i == _touchedLowStockIndex;
                  // Aumenta o raio (tamanho) se a fatia for tocada/hovered
                  final double radius = isTouched ? 40 : 35; 
                  final double fontSize = isTouched ? 13 : 12;

                  return PieChartSectionData(
                    value: sectionsData[i],
                    title: '${sectionsData[i].toInt()}',
                    color: sectionsColors[i],
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: isTouched
                          ? [
                              const Shadow(
                                  color: Colors.black45, blurRadius: 2)
                            ]
                          : null,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Legenda
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: List.generate(sectionsData.length, (i) {
              return _buildLegendItem(sectionsColors[i], sectionsLabels[i]);
            }),
          ),
        ],
      ),
    );
  }

  /// Helper para a legenda do gráfico de pizza de "Baixo Estoque"
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

  /// 📈 Gráfico: Total de Itens (PLACEHOLDER - Gráfico de Linha)
  Widget _buildTotalItemsChart() {
    // Dados de placeholder para o gráfico compilar
    final List<FlSpot> spots = [
      const FlSpot(0, 2),
      const FlSpot(1, 2.5),
      const FlSpot(2, 1.9),
      const FlSpot(3, 2.8),
      const FlSpot(4, 3),
      const FlSpot(5, 3.2),
      const FlSpot(6, 3.5),
    ];

    return SizedBox(
      width: 100, // Ajustado para o tamanho do sparkline
      height: 40,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 4,
          lineBarsData: [
            LineChartBarData(
              spots: spots, // Usando dados de placeholder
              isCurved: true,
              color: Colors.blue.shade800,
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

  /// 📊 Gráfico: Top 5 Materiais mais usados (DATA-DRIVEN)
  /// USA DADOS: _topfiveMaterials
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

    // --- [INÍCIO DA NOVA LÓGICA] ---

    // 1. Achar o valor máximo real, ou 0 se a lista estiver vazia
    final double maxVal = totals.isEmpty ? 0 : totals.reduce((a, b) => a > b ? a : b);

    // 2. Definir um maxY "bonito" e robusto
    double maxY;
    if (maxVal == 0) {
      maxY = 10.0; // Valor default se não houver dados (gráfico de 0 a 10)
    } else {
      // Adiciona 20% de padding e arredonda para cima para o próximo inteiro
      maxY = (maxVal * 1.2).ceilToDouble();
      // Garante um mínimo para o gráfico não ficar esmagado se o valor for 1 ou 2
      if (maxY < 5) {
        maxY = 5.0;
      }
    }

    // 3. Calcular um intervalo "bonito" (sempre um número inteiro)
    // Queremos ~4 divisões.
    double calculatedInterval = maxY / 4;
    double interval = calculatedInterval.ceilToDouble(); // Arredonda para cima

    // 4. Garantir que o intervalo nunca seja zero
    if (interval == 0) {
      interval = 1.0;
    }

    // --- [FIM DA NOVA LÓGICA] ---


    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < _topfiveMaterials.length; i++) {
      final double value = totals[i];
      barGroups.add(_buildBarGroup(i, value));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY, // [MODIFICADO] Usa o novo maxY robusto
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval, // [MODIFICADO] Usa o novo intervalo (inteiro)
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(), // Agora é seguro usar toInt()
                style: const TextStyle(fontSize: 10),
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
                
                final nome = _topfiveMaterials[idx]['material']?.toString() ?? '';
                return SideTitleWidget(
                  meta: meta,
                  space: 8.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 60),
                    child: Text(
                      nome,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 10),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (BarChartGroupData) {
              return Colors.blueGrey.shade700;
            },
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final nome =
                  _topfiveMaterials[groupIndex]['material'] ?? 'Desconhecido';
              return BarTooltipItem(
                '$nome\n${rod.toY.toInt()} movimentações',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }


  /// Helper para o gráfico de barras (DATA-DRIVEN)
  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 20,
          color: const Color(0xFF1763A6),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }


  Widget _buildCategoryDistributionChart() {
  if (_categoryDistribution.isEmpty) {
    return const Center(child: CircularProgressIndicator());
  }

  final totalGeral = _categoryDistribution.fold<int>(
      0, (sum, item) => sum + ((item['total'] ?? 0) as int));

  final colors = [
    const Color(0xFF1763A6),
    const Color(0xFF4A90E2),
    const Color(0xFF7AB8F5),
    const Color(0xFFA5D0F9),
    Colors.grey.shade400,
  ];

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
            sections: List.generate(_categoryDistribution.length, (i) {
              final total = ((_categoryDistribution[i]['total'] ?? 0) as int);
              final percent = (total / totalGeral) * 100;
              final isTouched = _touchedCategoryIndex == i;

              return PieChartSectionData(
                value: total.toDouble(),
                title: '${percent.toStringAsFixed(1)}%',
                color: colors[i % colors.length],
                radius: isTouched ? 70 : 60,
                titleStyle: TextStyle(
                  fontSize: isTouched ? 15 : 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        flex: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_categoryDistribution.length, (i) {
          final categoria = _categoryDistribution[i]['categoria']?.toString() ?? 'Sem categoria';
          final total = _categoryDistribution[i]['total'];
          final totalStr = (total != null) ? total.toString() : '0';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildCategoryLegendItem(
              colors[i % colors.length],
              categoria,
              totalStr,
              i,
            ),
          );
        }),
        ),
      ),
    ],
  );
}


  /// Helper para a legenda do gráfico de pizza (PLACEHOLDER / Estático)
  Widget _buildCategoryLegendItem(
      Color color, String label, String value, int index) {
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
}