import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../services/movimentation_services.dart';
import '../services/inventory_service.dart';
import 'dashBoardScreen.dart';


const kPrimaryColor = Color(0xFF1763A6);
const kWarningColor = Color(0xFFE67E22);
const kSuccessColor = Color(0xFF28A745);
const kDangerColor = Color(0xFFDC3545);



class ChartsByBaseScreen extends StatefulWidget {
  const ChartsByBaseScreen({super.key});

  @override
  State<ChartsByBaseScreen> createState() => _ChartsByBaseScreenState();
}

class _ChartsByBaseScreenState extends State<ChartsByBaseScreen> {
  // Serviços e dados
  MovementsToday? _movementsToday;
  final movimentationServices = MovimentationServices();
  final inventoryServices = InventoryServices();
  List<Map<String, dynamic>> _criticalItems = [];

  // Filtros
  String? _selectedBase;
  final List<String> _bases = ['Base Alpha', 'Base Beta', 'Base Gama']; // Mock

  // Dados dos Gráficos (MOCK)
  List<Map<String, dynamic>> _lowStockData = [];
  List<Map<String, dynamic>> _calibrationData = [];
  List<Map<String, dynamic>> _categoryDistribution = [];
  List<Map<String, dynamic>> _monthlyFlowData = [];

  // Estado de Interação
  int _touchedCategoryIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadMovements();
    _loadCriticalItems();
    _loadChartData();
  }

  // --- MÉTODOS DE CARREGAMENTO (sem alteração) ---

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

  void _loadChartData({String? base}) {
    // TODO: Substituir por chamadas reais de API
    print("Carregando dados para a base: ${base ?? 'Todas'}");

    setState(() {
      _lowStockData = [
        {'nome': 'Parafuso 8mm', 'qtd': 8},
        {'nome': 'Placa ZX-100', 'qtd': 5},
        {'nome': 'Sensor T-800', 'qtd': 3},
        {'nome': 'Cabo Flex 1m', 'qtd': 10},
        {'nome': 'Filtro de Ar', 'qtd': 2},
      ];

      _calibrationData = [
        {'mes': 'Nov', 'qtd': 5},
        {'mes': 'Dez', 'qtd': 8},
        {'mes': 'Jan', 'qtd': 3},
        {'mes': 'Fev', 'qtd': 12},
        {'mes': 'Mar', 'qtd': 7},
        {'mes': 'Abr', 'qtd': 5},
      ];

      _categoryDistribution = [
        {'categoria': 'Sensores', 'total': 45},
        {'categoria': 'Componentes', 'total': 70},
        {'categoria': 'Fixadores', 'total': 30},
        {'categoria': 'Fluidos', 'total': 15},
      ];

      _monthlyFlowData = [
        {'mes': 0, 'label': 'Mai', 'entradas': 120, 'saidas': 80},
        {'mes': 1, 'label': 'Jun', 'entradas': 150, 'saidas': 90},
        {'mes': 2, 'label': 'Jul', 'entradas': 180, 'saidas': 110},
        {'mes': 3, 'label': 'Ago', 'entradas': 130, 'saidas': 140},
        {'mes': 4, 'label': 'Set', 'entradas': 160, 'saidas': 120},
        {'mes': 5, 'label': 'Out', 'entradas': 190, 'saidas': 130},
      ];
    });
  }

  // --- BUILD WIDGET (sem alteração) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const BarMenu(),
      drawer: const VerticalMenu(selectedIndex: 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildBaseFilters(context),
              const SizedBox(height: 24),
              _buildInfoCards(context),
              const SizedBox(height: 24),
              _buildMainChartsRow(context),
              const SizedBox(height: 24),
              _buildSecondaryChartsRow(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS DE CONSTRUÇÃO DE SEÇÃO (com bordas atualizadas) ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        'Dashboard por Base',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildBaseFilters(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // (BORDA ATUALIZADA)
        side: BorderSide(color: kPrimaryColor.withOpacity(0.4), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.filter_list, color: kPrimaryColor, size: 20),
            const SizedBox(width: 12),
            const Text(
              'Filtrar por Base:',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)),
            ),
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBase,
                  isDense: true,
                  hint: const Text('Selecione uma base'),
                  items: _bases.map((String base) {
                    return DropdownMenuItem<String>(
                      value: base,
                      child: Text(base),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBase = newValue;
                    });
                    _loadChartData(base: newValue);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    final entradas = _movementsToday?.entradas ?? 0;
    final saidas = _movementsToday?.saidas ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInfoCard(
            title: 'Movimentações Hoje',
            icon: Icons.sync_alt,
            iconColor: Colors.blue.shade700, // Cor base para a borda
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entradas: $entradas',
                    style: const TextStyle(fontSize: 14)),
                Text('Saídas: $saidas', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildInfoCard(
            title: 'Itens Críticos',
            icon: Icons.error_outline,
            iconColor: Colors.red.shade700, // Cor base para a borda
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _criticalItems.isEmpty
                  ? [const Text('Nenhum item crítico no momento.')]
                  : _criticalItems
                      .map((item) {
                        return Text(
                          '${item['nome_material']} (Estoque: ${item['quantidade']})',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        );
                      })
                      .toList()
                      .take(3)
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainChartsRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildLowStockBarChart(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildCalibrationChart(),
        ),
      ],
    );
  }

  Widget _buildSecondaryChartsRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildCategoryDistributionChart(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildMonthlyFlowLineChart(),
        ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES REUTILIZÁVEIS ---

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget content,
    Color iconColor = kPrimaryColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // (BORDA ATUALIZADA) Usa a cor do ícone
        side: BorderSide(color: iconColor.withOpacity(0.4), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800]),
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

  // --- GRÁFICOS (com bordas atualizadas) ---

  Widget _buildLowStockBarChart() {
    if (_lowStockData.isEmpty) {
      return const Card(
          child: Center(heightFactor: 8, child: CircularProgressIndicator()));
    }
    final double maxVal = _lowStockData
        .map<double>((e) => (e['qtd'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    final double maxY = (maxVal * 1.2).ceilToDouble();
    final double interval = (maxY / 4).ceilToDouble();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // (BORDA ATUALIZADA)
        side: BorderSide(color: kWarningColor.withOpacity(0.4), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Materiais com Estoque Baixo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(
                BarChartData(
                  // ... (resto do BarChartData)
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: interval > 0 ? interval : 1,
                        getTitlesWidget: (value, meta) =>
                            Text(value.toInt().toString()),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int idx = value.toInt();
                          if (idx < 0 || idx >= _lowStockData.length) {
                            return const SizedBox.shrink();
                          }
                          final nome = _lowStockData[idx]['nome'].toString();
                          return SideTitleWidget(
                            meta: meta,
                            space: 8.0,
                            child: Text(
                              nome,
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 10),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (BarChartGroupData) =>
                          Colors.blueGrey.shade700,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = _lowStockData[groupIndex];
                        return BarTooltipItem(
                          '${item['nome']}\n${(item['qtd'] as num).toInt()} unidades',
                          const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  barGroups: List.generate(_lowStockData.length, (i) {
                    return _buildBarGroup(
                      i,
                      (_lowStockData[i]['qtd'] as num).toDouble(),
                      color: kWarningColor,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationChart() {
    if (_calibrationData.isEmpty) {
      return const Card(
          child: Center(heightFactor: 8, child: CircularProgressIndicator()));
    }
    final double maxVal = _calibrationData
        .map<double>((e) => (e['qtd'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    final double maxY = (maxVal * 1.2).ceilToDouble();
    final double interval = (maxY / 4).ceilToDouble();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // (BORDA ATUALIZADA)
        side: BorderSide(color: kPrimaryColor.withOpacity(0.4), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calendário de Calibração',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(
                BarChartData(
                  // ... (resto do BarChartData)
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: interval > 0 ? interval : 1,
                        getTitlesWidget: (value, meta) =>
                            Text(value.toInt().toString()),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int idx = value.toInt();
                          if (idx < 0 || idx >= _calibrationData.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            space: 4.0,
                            child: Text(
                              _calibrationData[idx]['mes'].toString(),
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (BarChartGroupData) =>
                          Colors.blueGrey.shade700,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = _calibrationData[groupIndex];
                        return BarTooltipItem(
                          '${item['mes']}\n${(item['qtd'] as num).toInt()} calibrações',
                          const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  barGroups: List.generate(_calibrationData.length, (i) {
                    return _buildBarGroup(
                      i,
                      (_calibrationData[i]['qtd'] as num).toDouble(),
                      color: kPrimaryColor,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionChart() {
    if (_categoryDistribution.isEmpty) {
      return const Card(
          child: Center(heightFactor: 8, child: CircularProgressIndicator()));
    }
    final totalGeral = _categoryDistribution.fold<int>(
        0, (sum, item) => sum + ((item['total'] ?? 0) as int));
    final colors = [
      kPrimaryColor,
      Colors.blue.shade300,
      kWarningColor,
      Colors.orange.shade200,
      Colors.grey.shade400,
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // (BORDA ATUALIZADA)
        side: BorderSide(color: kPrimaryColor.withOpacity(0.4), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distribuição por Categorias',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.6,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: PieChart(
                      PieChartData(
                        // ... (resto do PieChartData)
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedCategoryIndex = -1;
                                return;
                              }
                              _touchedCategoryIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: List.generate(_categoryDistribution.length, (i) {
                          final total =
                              ((_categoryDistribution[i]['total'] ?? 0) as int);
                          final percent = (total / totalGeral) * 100;
                          final isTouched = _touchedCategoryIndex == i;

                          return PieChartSectionData(
                            value: total.toDouble(),
                            title: '${percent.toStringAsFixed(0)}%',
                            color: colors[i % colors.length],
                            radius: isTouched ? 70 : 60,
                            titleStyle: TextStyle(
                              fontSize: isTouched ? 15 : 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(color: Colors.black26, blurRadius: 2)
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(_categoryDistribution.length, (i) {
                        final categoria =
                            _categoryDistribution[i]['categoria']?.toString() ??
                                'Sem categoria';
                        final total = _categoryDistribution[i]['total'];
                        final totalStr = (total != null) ? total.toString() : '0';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildPieChartLegendItem(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📈 Gráfico: Fluxo de Estoque Mensal
  Widget _buildMonthlyFlowLineChart() {
    if (_monthlyFlowData.isEmpty) {
      return const Card(
          child: Center(heightFactor: 8, child: CircularProgressIndicator()));
    }
    final double maxEntrada = _monthlyFlowData
        .map<double>((e) => (e['entradas'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    final double maxSaida = _monthlyFlowData
        .map<double>((e) => (e['saidas'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    final double maxY = (maxEntrada > maxSaida ? maxEntrada : maxSaida) * 1.2;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // (BORDA ATUALIZADA)
        side: BorderSide(color: kPrimaryColor.withOpacity(0.4), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fluxo de Estoque Mensal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSimpleLegendItem(kSuccessColor, 'Entradas'),
                const SizedBox(width: 20),
                _buildSimpleLegendItem(kDangerColor, 'Saídas'),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.6,
              child: LineChart(
                LineChartData(
                  // ... (resto do LineChartData)
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: maxY / 4,
                        getTitlesWidget: (value, meta) =>
                            Text(value.toInt().toString()),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int idx = value.toInt();
                          if (idx < 0 || idx >= _monthlyFlowData.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            space: 4.0,
                            child: Text(
                              _monthlyFlowData[idx]['label'].toString(),
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (_monthlyFlowData.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => Colors.blueGrey.shade800,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          final int idx = flSpot.x.toInt();
                          final data = _monthlyFlowData[idx];
                          return LineTooltipItem(
                            '${data['label']}\n'
                            'Entradas: ${data['entradas']}\n'
                            'Saídas: ${data['saidas']}',
                            const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                  lineBarsData: [
                    _buildLineChartBarData(
                      _monthlyFlowData
                          .map((e) => FlSpot((e['mes'] as num).toDouble(),
                              (e['entradas'] as num).toDouble()))
                          .toList(),
                      kSuccessColor,
                    ),
                    _buildLineChartBarData(
                      _monthlyFlowData
                          .map((e) => FlSpot((e['mes'] as num).toDouble(),
                              (e['saidas'] as num).toDouble()))
                          .toList(),
                      kDangerColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPERS (sem alteração) ---

  Widget _buildPieChartLegendItem(
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
            overflow: TextOverflow.ellipsis,
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

  BarChartGroupData _buildBarGroup(int x, double y,
      {Color color = kPrimaryColor}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 20,
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
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

  LineChartBarData _buildLineChartBarData(
      List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildSimpleLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            )),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}