import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../services/movimentation_services.dart';
import '../services/inventory_service.dart';
import 'dashBoardScreen.dart'; // Importação mantida

// Cores com o mesmo toque moderno e suave da tela anterior
const kPrimaryColor = Color(0xFF007BFF); // Azul mais vibrante
const kWarningColor = Color(0xFFFFC107); // Amarelo mais padrão
const kSuccessColor = Color(0xFF28A745);
const kDangerColor = Color(0xFFDC3545);
const kBackgroundColor = Color(0xFFF4F7F9); // Fundo suave
const kCardColor = Colors.white;
const kTextColor = Color(0xFF343A40); // Texto escuro

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

  // --- BUILD WIDGET ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // Fundo suave
      appBar: const BarMenu(),
      drawer: const VerticalMenu(selectedIndex: 10),
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


  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        'Dashboard por Base',
        style: TextStyle(
          fontSize: 32, // Aumentado
          fontWeight: FontWeight.w800, // Mais forte
          color: kTextColor,
        ),
      ),
    );
  }

  Widget _buildBaseFilters(BuildContext context) {
    return _buildCardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.filter_list, color: kPrimaryColor, size: 24),
          const SizedBox(width: 16),
          const Text(
            'Filtrar por Base:',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kTextColor),
          ),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBase,
                isDense: true,
                hint: Text('Selecione uma base', style: TextStyle(color: kTextColor.withOpacity(0.7))),
                items: _bases.map((String base) {
                  return DropdownMenuItem<String>(
                    value: base,
                    child: Text(base, style: const TextStyle(color: kTextColor)),
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
            iconColor: kPrimaryColor,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entradas: $entradas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kSuccessColor)),
                Text('Saídas: $saidas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kDangerColor)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildInfoCard(
            title: 'Itens Críticos',
            icon: Icons.error_outline,
            iconColor: kDangerColor,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _criticalItems.isEmpty
                  ? [const Text('Nenhum item crítico no momento.', style: TextStyle(color: kSuccessColor, fontWeight: FontWeight.w500))]
                  : _criticalItems
                      .map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '${item['nome_material']} (Estoque: ${item['quantidade']})',
                            style: const TextStyle(fontSize: 14, color: kTextColor),
                            overflow: TextOverflow.ellipsis,
                          ),
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

  // Novo helper para o container de Card (Reutilizado da tela anterior)
  Widget _buildCardContainer({required Widget child, EdgeInsets? padding}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: kCardColor,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24), // Padding padrão de 24
        child: child,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget content,
    Color iconColor = kPrimaryColor,
  }) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: iconColor.withOpacity(0.1),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF0F0F0)),
          content,
        ],
      ),
    );
  }


  Widget _buildLowStockBarChart() {
    if (_lowStockData.isEmpty) {
      return _buildCardContainer(
          child: const Center(
              heightFactor: 8, child: CircularProgressIndicator()));
    }

    final List<double> totals = _lowStockData.map<double>((e) {
      return (e['qtd'] as num).toDouble();
    }).toList();

    final double maxVal =
        totals.isEmpty ? 0 : totals.reduce((a, b) => a > b ? a : b);
    double maxX = (maxVal * 1.2).ceilToDouble();
    if (maxX < 5) maxX = 5.0;

    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top 5 Itens com Estoque Baixo',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor)),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.2,
            child: RotatedBox(
              quarterTurns: 1,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxX,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      rotateAngle: -90, 
                      getTooltipColor: (group) => kDangerColor.withOpacity(0.9),
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = _lowStockData[groupIndex];
                        return BarTooltipItem(
                          '${item['nome']}\nEstoque: ${item['qtd']}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 110,
                        getTitlesWidget: (value, meta) {
                          final int idx = value.toInt();
                          if (idx < 0 || idx >= _lowStockData.length) {
                            return const SizedBox.shrink();
                          }
                        
                          return SideTitleWidget(
                            meta: meta,
                            space: 10, 
                            child: RotatedBox(
                              quarterTurns: -1,
                              child: Text(
                                _lowStockData[idx]['nome'].toString(),
                                style: TextStyle(
                                  color: kTextColor.withOpacity(0.8),
                                  fontSize: 11, 
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxX / 4,
                        getTitlesWidget: (value, meta) {
                          
                          return SideTitleWidget(
                            meta: meta,
                            child: RotatedBox(
                              quarterTurns: -1,
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: kTextColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                 
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false, 
                    drawHorizontalLine: true, 
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
                      
                      bottom:
                          BorderSide(color: Colors.grey.shade300, width: 1), 
                      right:
                          BorderSide(color: Colors.grey.shade300, width: 1), 
                      left: BorderSide.none,
                      top: BorderSide.none,
                    ),
                  ),
                  barGroups: List.generate(_lowStockData.length, (i) {
                    return _buildBarGroup(
                      i,
                      (_lowStockData[i]['qtd'] as num).toDouble(),
                      color: kDangerColor,
                    );
                  }),
                ),
                swapAnimationDuration: const Duration(milliseconds: 150),
                swapAnimationCurve: Curves.linear,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildCalibrationChart() {
    if (_calibrationData.isEmpty) {
      return _buildCardContainer(
          child: const Center(heightFactor: 8, child: CircularProgressIndicator()));
    }

    final List<double> totals = _calibrationData.map<double>((e) {
      return (e['qtd'] as num).toDouble();
    }).toList();

    final double maxVal = totals.isEmpty ? 0 : totals.reduce((a, b) => a > b ? a : b);
    double maxY = (maxVal * 1.2).ceilToDouble();
    if (maxY < 5) maxY = 5.0;
    double calculatedInterval = maxY / 4;
    double interval = calculatedInterval.ceilToDouble();
    if (interval == 0) interval = 1.0;

    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calibrações por Mês',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor)),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.2,
            child: BarChart(
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
                        style: TextStyle(fontSize: 10, color: kTextColor.withOpacity(0.7)),
                      ),
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
                            style: TextStyle(
                                color: kTextColor.withOpacity(0.8), fontSize: 12),
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
                    getTooltipColor: (group) => kPrimaryColor.withOpacity(0.9),
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


  Widget _buildCategoryDistributionChart() {
    if (_categoryDistribution.isEmpty) {
      return _buildCardContainer(
          child: const Center(heightFactor: 8, child: CircularProgressIndicator()));
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

    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribuição por Categorias',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor)),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.6,
            child: Row(
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
                            _touchedCategoryIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sectionsSpace: 4, 
                      centerSpaceRadius: 60, 
                      sections: List.generate(_categoryDistribution.length, (i) {
                        final total =
                            ((_categoryDistribution[i]['total'] ?? 0) as int);
                        final percent = (total / totalGeral) * 100;
                        final isTouched = _touchedCategoryIndex == i;

                        return PieChartSectionData(
                          value: total.toDouble(),
                          title: '${percent.toStringAsFixed(0)}%',
                          color: colors[i % colors.length],
                          radius: isTouched ? 80 : 70, 
                          titleStyle: TextStyle(
                            fontSize: isTouched ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(color: Colors.black45, blurRadius: 3)
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
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
                        padding: const EdgeInsets.only(bottom: 10.0),
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
    );
  }

 
  Widget _buildPieChartLegendItem(
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

 
  Widget _buildMonthlyFlowLineChart() {
    if (_monthlyFlowData.isEmpty) {
      return _buildCardContainer(
          child: const Center(heightFactor: 8, child: CircularProgressIndicator()));
    }
    final double maxEntrada = _monthlyFlowData
        .map<double>((e) => (e['entradas'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    final double maxSaida = _monthlyFlowData
        .map<double>((e) => (e['saidas'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    final double maxY = (maxEntrada > maxSaida ? maxEntrada : maxSaida) * 1.2;
    double interval = (maxY / 4).ceilToDouble();
    if (interval == 0) interval = 1.0;

    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fluxo de Estoque Mensal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor)),
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
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
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
                      reservedSize: 40,
                      interval: interval,
                      getTitlesWidget: (value, meta) =>
                          Text(value.toInt().toString(), style: TextStyle(fontSize: 10, color: kTextColor.withOpacity(0.7))),
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
                            style: TextStyle(
                                color: kTextColor.withOpacity(0.8), fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                minX: 0,
                maxX: (_monthlyFlowData.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (group) => kTextColor.withOpacity(0.9),
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
            color.withOpacity(0.2), 
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
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            )),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(fontSize: 13, color: kTextColor.withOpacity(0.8), fontWeight: FontWeight.w500)),
      ],
    );
  }
}
