import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../services/movimentation_services.dart';
import '../services/inventory_service.dart';
import '../services/base_filter_services.dart';
import '../utils/models/location.dart';
import 'dashboard_screen.dart';

const kPrimaryColor = Color(0xFF007BFF);
const kWarningColor = Color(0xFFFFC107);
const kSuccessColor = Color(0xFF28A745);
const kDangerColor = Color(0xFFDC3545);
const kBackgroundColor = Color(0xFFF4F7F9);
const kCardColor = Colors.white;
const kTextColor = Color(0xFF343A40);

class ChartsByBaseScreen extends StatefulWidget {
  const ChartsByBaseScreen({super.key});

  @override
  State<ChartsByBaseScreen> createState() => _ChartsByBaseScreenState();
}

class _ChartsByBaseScreenState extends State<ChartsByBaseScreen> {
  MovementsToday? _movementsToday;
  final movimentationServices = MovimentationServices();
  final inventoryServices = InventoryServices();
  final baseFilterServices = BaseFilterServices();
  List<Map<String, dynamic>> _criticalItems = [];

  bool _hasError = false;
  bool _isLoadingCharts = false;

  String _monthLabelFromNumber(int num) {
    const months = {
      1: 'Jan',
      2: 'Fev',
      3: 'Mar',
      4: 'Abr',
      5: 'Mai',
      6: 'Jun',
      7: 'Jul',
      8: 'Ago',
      9: 'Set',
      10: 'Out',
      11: 'Nov',
      12: 'Dez',
    };
    return months[num] ?? num.toString();
  }

  SimpleLocation? _selectedBase;
  List<SimpleLocation> _bases = [];
  bool _isLoadingBases = true;

  List<Map<String, dynamic>> _lowStockData = [];
  List<Map<String, dynamic>> _calibrationData = [];
  List<Map<String, dynamic>> _categoryDistribution = [];
  List<Map<String, dynamic>> _monthlyFlowData = [];

  final double _secondaryChartHeight = 340.0;
  int _touchedCategoryIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadBases();
    _loadMovements();
    _loadCriticalItems();
  }

  Future<void> _loadChartData({SimpleLocation? base}) async {
    setState(() {
      _isLoadingCharts = true;
      _hasError = false;
      _lowStockData = [];
      _categoryDistribution = [];
      _calibrationData = [];
      _monthlyFlowData = [];
    });

    if (base == null) {
      setState(() => _isLoadingCharts = false);
      return;
    }

    try {
      final results = await Future.wait([
        baseFilterServices.getBaseLowStock(base.id),
        baseFilterServices.getBaseCategoryDistribution(base.id),
        baseFilterServices.getBaseMonthCalibration(base.id),
        baseFilterServices.getFluxoMensal(base.id),
        baseFilterServices.getBaseMovementsToday(base.id),
        baseFilterServices.getBaseCriticalItens(base.id),
      ]);

      final low = results[0];
      final distribution = results[1];
      final calibration = results[2];
      final fluxo = results[3];
      final movToday = results[4];
      final critical = results[5];

      final lowMapped = low.map<Map<String, dynamic>>((e) {
        final nome = e['nome_material'] ?? e['nome'] ?? '';
        final rawQtd = e['quantidade'] ?? e['quantidade_total'] ?? 0;
        final qtd = (double.tryParse(rawQtd.toString()) ?? 0).toInt();
        return {'nome': nome.toString(), 'qtd': qtd};
      }).toList();

      final distMapped = distribution.map<Map<String, dynamic>>((e) {
        final rawTotal = e['total'] ?? 0;
        return {
          'categoria': e['categoria'] ?? e['nome_categoria'] ?? 'Sem categoria',
          'total': (double.tryParse(rawTotal.toString()) ?? 0).toInt(),
        };
      }).toList();

      final calibMapped = calibration.map<Map<String, dynamic>>((e) {
        final mesVal = e['mes'];
        final mesLabel = mesVal is int
            ? _monthLabelFromNumber(mesVal)
            : mesVal?.toString() ?? '';
        final rawQtd = e['total'] ?? e['qtd'] ?? 0;
        final qtd = (double.tryParse(rawQtd.toString()) ?? 0).toInt();
        return {'mes': mesLabel, 'qtd': qtd};
      }).toList();

      final fluxoMapped = fluxo.map<Map<String, dynamic>>((e) {
        return {
          'mes': e['mes'] ?? 0,
          'label': e['mes']?.toString() ?? '',
          'entradas': (double.tryParse(
                      (e['total_entradas'] ?? e['entradas'] ?? 0).toString()) ??
                  0)
              .toInt(),
          'saidas': (double.tryParse(
                      (e['total_saidas'] ?? e['saidas'] ?? 0).toString()) ??
                  0)
              .toInt(),
        };
      }).toList();

      MovementsToday? movs;
      if (movToday.isNotEmpty) {
        final d = movToday.first as Map<String, dynamic>;
        movs = MovementsToday(
          entradas:
              (double.tryParse((d['entradas'] ?? 0).toString()) ?? 0).toInt(),
          saidas: (double.tryParse((d['saidas'] ?? 0).toString()) ?? 0).toInt(),
        );
      }

      setState(() {
        _lowStockData = lowMapped;
        _categoryDistribution = distMapped;
        _calibrationData = calibMapped;
        _monthlyFlowData = fluxoMapped;
        if (movs != null) _movementsToday = movs;
        _criticalItems = List<Map<String, dynamic>>.from(critical);
        _isLoadingCharts = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar charts: $e');
      setState(() {
        _hasError = true;
        _isLoadingCharts = false;
      });
    }
  }

  Future<void> _loadBases() async {
    setState(() => _isLoadingBases = true);
    try {
      final lista = await inventoryServices.getAllLocations();
      setState(() {
        _bases = lista;
        _isLoadingBases = false;
        if (_bases.isNotEmpty) {
          _selectedBase = _bases.first;
          _loadChartData(base: _selectedBase);
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingBases = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadMovements() async {
    try {
      if (_selectedBase != null) {
        final data =
            await baseFilterServices.getBaseMovementsToday(_selectedBase!.id);
        if (data.isNotEmpty) {
          final Map<String, dynamic> d = data.first;
          setState(() {
            _movementsToday = MovementsToday(
              entradas: (double.tryParse(d['entradas']?.toString() ?? '0') ?? 0)
                  .toInt(),
              saidas: (double.tryParse(d['saidas']?.toString() ?? '0') ?? 0)
                  .toInt(),
            );
          });
        }
      }
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  Future<void> _loadCriticalItems() async {
    try {
      if (_selectedBase != null) {
        final items =
            await baseFilterServices.getBaseCriticalItens(_selectedBase!.id);
        setState(() {
          _criticalItems = List<Map<String, dynamic>>.from(items);
        });
      } else {
        final items = await InventoryServices().getCriticalItems();
        setState(() => _criticalItems = items);
      }
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: const BarMenu(),
      drawer: const VerticalMenu(selectedIndex: 10),

      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 900;
          double padding = isMobile ? 16.0 : 32.0;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, isMobile),
                  const SizedBox(height: 24),
                  _buildBaseFilters(context, isMobile),
                  const SizedBox(height: 24),
                  _buildInfoCards(context, isMobile),
                  const SizedBox(height: 32),
                  _buildMainChartsRow(context, isMobile),
                  const SizedBox(height: 32),
                  _buildSecondaryChartsRow(context, isMobile),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBaseFilters(BuildContext context, bool isMobile) {
    Widget dropdownWidget = Container(
     
      width: isMobile ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoadingBases
          ? const SizedBox(
              width: 150,
              height: 40,
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kPrimaryColor))))
          : DropdownButtonHideUnderline(
              child: DropdownButton<SimpleLocation>(
                value: _selectedBase,
                icon: const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                isDense: true,
                isExpanded: isMobile, 
                hint: Text('Selecione',
                    style: TextStyle(color: kTextColor.withOpacity(0.7))),
                items: _bases.map((SimpleLocation base) {
                  return DropdownMenuItem<SimpleLocation>(
                    value: base,
                    child: Text(base.nome,
                        style: const TextStyle(
                            color: kTextColor, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (SimpleLocation? newValue) {
                  setState(() {
                    _selectedBase = newValue;
                  });
                  _loadChartData(base: newValue);
                },
              ),
            ),
    );

    return _buildCardContainer(
      borderColor: kPrimaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list,
                        color: kPrimaryColor, size: 24),
                    const SizedBox(width: 16),
                    Text(
                      'Filtrar por Base:',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                dropdownWidget, 
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.filter_list, color: kPrimaryColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Filtrar por Base:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kTextColor),
                  ),
                ),
                dropdownWidget, 
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard por Base',
          style: TextStyle(
            fontSize: isMobile ? 28 : 36, 
            fontWeight: FontWeight.w900,
            color: const Color(0xFF082583),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Visão geral e detalhada dos dados de estoque e movimentação por base.',
          style: TextStyle(
            fontSize: 16,
            color: kTextColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(BuildContext context, bool isMobile) {
    final entradas = _movementsToday?.entradas ?? 0;
    final saidas = _movementsToday?.saidas ?? 0;

    final cardEntradas = _buildInfoCard(
      title: 'Entradas Hoje',
      icon: Icons.arrow_downward,
      iconColor: kSuccessColor,
      borderColor: kSuccessColor,
      content: Text(
        entradas.toString(),
        style: const TextStyle(
            fontSize: 42, fontWeight: FontWeight.w900, color: kTextColor),
      ),
    );

    final cardSaidas = _buildInfoCard(
      title: 'Saídas Hoje',
      icon: Icons.arrow_upward,
      iconColor: kDangerColor,
      borderColor: kDangerColor,
      content: Text(
        saidas.toString(),
        style: const TextStyle(
            fontSize: 42, fontWeight: FontWeight.w900, color: kTextColor),
      ),
    );

    final cardCriticos = _buildInfoCard(
      title: 'Itens Críticos (Nesta Base)',
      icon: Icons.warning_amber_rounded,
      iconColor: kWarningColor,
      borderColor: kWarningColor,
      content: _hasError
          ? _buildErrorMsg()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _criticalItems.isEmpty
                  ? [
                      const Text('Nenhum item crítico.',
                          style: TextStyle(
                              fontSize: 16,
                              color: kSuccessColor,
                              fontWeight: FontWeight.w500))
                    ]
                  : _criticalItems
                      .map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '${item['nome_material']} (Estoque: ${item['quantidade']})',
                            style: const TextStyle(
                                fontSize: 14, color: kTextColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      })
                      .toList()
                      .take(3)
                      .toList(),
            ),
    );

    if (isMobile) {
      return Column(
        children: [
          cardEntradas,
          const SizedBox(height: 16),
          cardSaidas,
          const SizedBox(height: 16),
          cardCriticos,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: cardEntradas),
          const SizedBox(width: 32),
          Expanded(child: cardSaidas),
          const SizedBox(width: 32),
          Expanded(child: cardCriticos),
        ],
      );
    }
  }

  Widget _buildMainChartsRow(BuildContext context, bool isMobile) {
    final fluxoChart = _buildMonthlyFlowLineChart();
    final pizzaChart = _buildCategoryDistributionChart(isMobile);

    if (isMobile) {
      return Column(
        children: [
          fluxoChart,
          const SizedBox(height: 24),
          pizzaChart,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: fluxoChart,
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 2,
            child: pizzaChart,
          ),
        ],
      );
    }
  }

  Widget _buildSecondaryChartsRow(BuildContext context, bool isMobile) {
    final lowStockChart = _buildLowStockBarChart();
    final calibrationChart = _buildCalibrationChart();

    if (isMobile) {
      return Column(
        children: [
          lowStockChart,
          const SizedBox(height: 24),
          calibrationChart,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: lowStockChart,
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 1,
            child: calibrationChart,
          ),
        ],
      );
    }
  }

  Widget _buildErrorMsg() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, color: kDangerColor, size: 30),
      const SizedBox(height: 8),
      const Text('Erro ao carregar dados',
          style: TextStyle(color: kDangerColor, fontWeight: FontWeight.bold))
    ]));
  }

  Widget _buildEmptyMsg() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.info_outline, color: kTextColor.withOpacity(0.5), size: 30),
      const SizedBox(height: 8),
      Text('Nenhuma informação disponível',
          style: TextStyle(
              color: kTextColor.withOpacity(0.6), fontWeight: FontWeight.w500))
    ]));
  }

  Widget _buildCardContainer(
      {required Widget child, EdgeInsets? padding, Color? borderColor}) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: borderColor?.withOpacity(0.5) ?? Colors.grey.shade300,
              width: 1.5)),
      color: kCardColor,
      child:
          Padding(padding: padding ?? const EdgeInsets.all(24), child: child),
    );
  }

  Widget _buildInfoCard(
      {required String title,
      required IconData icon,
      required Widget content,
      Color iconColor = kPrimaryColor,
      Color? borderColor}) {
    return _buildCardContainer(
      borderColor: borderColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextColor.withOpacity(0.8))),
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 32))
          ]),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildLowStockBarChart() {
    if (_isLoadingCharts)
      return _buildCardContainer(
          borderColor: kDangerColor,
          child: const Center(
              heightFactor: 8, child: CircularProgressIndicator()));
    if (_hasError)
      return _buildCardContainer(
          borderColor: kDangerColor, child: _buildErrorMsg());
    if (_lowStockData.isEmpty)
      return _buildCardContainer(
          borderColor: kDangerColor,
          child: const SizedBox(
              height: 200, child: Center(child: Text("Estoque normal"))));

    final List<double> totals =
        _lowStockData.map<double>((e) => (e['qtd'] as num).toDouble()).toList();
    final double maxVal =
        totals.isEmpty ? 0 : totals.reduce((a, b) => a > b ? a : b);
    double maxY = ((maxVal * 1.2) / 5).ceil() * 5.0;
    if (maxY < 5) maxY = 5.0;
    double interval = maxY / 5;
    if (interval == 0) interval = 1;

    return _buildCardContainer(
      borderColor: kDangerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Itens com Estoque Baixo',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kTextColor)),
          const SizedBox(height: 16),
          SizedBox(
            height: _secondaryChartHeight,
            child: RotatedBox(
              quarterTurns: 1,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                          rotateAngle: -90,
                          getTooltipColor: (group) =>
                              kDangerColor.withOpacity(0.9),
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final item = _lowStockData[groupIndex];
                            return BarTooltipItem(
                                '${item['nome']}\nEstoque: ${item['qtd']}',
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold));
                          })),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 110,
                            getTitlesWidget: (value, meta) {
                              final int idx = value.toInt();
                              if (idx < 0 || idx >= _lowStockData.length)
                                return const SizedBox.shrink();
                              return SideTitleWidget(
                                  meta: meta,
                                  space: 10,
                                  child: RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                          _lowStockData[idx]['nome'].toString(),
                                          style: TextStyle(
                                              color:
                                                  kTextColor.withOpacity(0.8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1)));
                            })),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: interval,
                            getTitlesWidget: (value, meta) => SideTitleWidget(
                                meta: meta,
                                child: RotatedBox(
                                    quarterTurns: -1,
                                    child: Text(value.toInt().toString(),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: kTextColor
                                                .withOpacity(0.7))))))),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      drawHorizontalLine: true,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                      _lowStockData.length,
                      (i) => _buildBarGroup(
                          i, (_lowStockData[i]['qtd'] as num).toDouble(),
                          color: kDangerColor)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationChart() {
    if (_isLoadingCharts)
      return _buildCardContainer(
          borderColor: kPrimaryColor,
          child: const Center(
              heightFactor: 8, child: CircularProgressIndicator()));
    if (_hasError)
      return _buildCardContainer(
          borderColor: kPrimaryColor, child: _buildErrorMsg());
    if (_calibrationData.isEmpty)
      return _buildCardContainer(
          borderColor: kPrimaryColor, child: _buildEmptyMsg());

    double maxVal = 0;
    for (var item in _calibrationData) {
      double val = (item['qtd'] as num).toDouble();
      if (val > maxVal) maxVal = val;
    }
    double maxY = (maxVal > 0 ? maxVal * 1.2 : 5.0);
    maxY = (maxY / 5).ceil() * 5.0;
    double interval = maxY / 5;
    if (interval == 0) interval = 1;

    return _buildCardContainer(
      borderColor: kPrimaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calibrações por Mês',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kTextColor)),
          const SizedBox(height: 16),
          SizedBox(
            height: _secondaryChartHeight,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: interval,
                          getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: kTextColor.withOpacity(0.7))))),
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final int idx = value.toInt();
                            if (idx < 0 || idx >= _calibrationData.length)
                              return const SizedBox.shrink();
                            return SideTitleWidget(
                                meta: meta,
                                space: 4.0,
                                child: Text(
                                    _calibrationData[idx]['mes'].toString(),
                                    style: TextStyle(
                                        color: kTextColor.withOpacity(0.8),
                                        fontSize: 12)));
                          })),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) =>
                            kPrimaryColor.withOpacity(0.9),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final item = _calibrationData[groupIndex];
                          return BarTooltipItem(
                              '${item['mes']}\n${(item['qtd'] as num).toInt()} calibrações',
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold));
                        })),
                barGroups: List.generate(
                    _calibrationData.length,
                    (i) => _buildBarGroup(
                        i, (_calibrationData[i]['qtd'] as num).toDouble(),
                        color: kPrimaryColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistributionChart(bool isMobile) {
    if (_isLoadingCharts)
      return _buildCardContainer(
          borderColor: kPrimaryColor,
          child: const Center(
              heightFactor: 8, child: CircularProgressIndicator()));
    if (_hasError)
      return _buildCardContainer(
          borderColor: kPrimaryColor, child: _buildErrorMsg());
    if (_categoryDistribution.isEmpty)
      return _buildCardContainer(
          borderColor: kPrimaryColor, child: _buildEmptyMsg());

    final totalGeral = _categoryDistribution.fold<int>(
        0, (sum, item) => sum + ((item['total'] ?? 0) as int));
    final colors = [
      kPrimaryColor,
      const Color(0xFF17A2B8),
      kWarningColor,
      const Color(0xFF6C757D),
      const Color(0xFF20C997)
    ];

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
        centerSpaceRadius: isMobile ? 40 : 60,
        sections: List.generate(_categoryDistribution.length, (i) {
          final total = ((_categoryDistribution[i]['total'] ?? 0) as int);
          final percent = totalGeral > 0 ? (total / totalGeral) * 100 : 0.0;
          final isTouched = _touchedCategoryIndex == i;
          return PieChartSectionData(
            value: total.toDouble(),
            title: '${percent.toStringAsFixed(0)}%',
            color: colors[i % colors.length],
            radius: isTouched ? (isMobile ? 60 : 80) : (isMobile ? 50 : 70),
            titleStyle: TextStyle(
                fontSize: isTouched ? 16 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [Shadow(color: Colors.black45, blurRadius: 3)]),
          );
        }),
      ),
    );

    final legend = Column(
      children: List.generate(_categoryDistribution.length, (i) {
        final categoria = _categoryDistribution[i]['categoria']?.toString() ??
            'Sem categoria';
        final total = _categoryDistribution[i]['total'];
        final totalStr = (total != null) ? total.toString() : '0';
        return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildCategoryLegendItem(
                colors[i % colors.length], categoria, totalStr, i));
      }),
    );

    return _buildCardContainer(
      borderColor: kPrimaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribuição por Categorias',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kTextColor)),
          const SizedBox(height: 16),

          isMobile
              ? Column(children: [
                  SizedBox(height: 250, child: pieChart),
                  const SizedBox(height: 24),
                  legend
                ])
              : Row(children: [
                  Expanded(
                      flex: 4, child: SizedBox(height: 300, child: pieChart)),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: legend)
                ]),
        ],
      ),
    );
  }

  Widget _buildMonthlyFlowLineChart() {
    if (_isLoadingCharts)
      return _buildCardContainer(
          borderColor: kPrimaryColor,
          child: const Center(
              heightFactor: 8, child: CircularProgressIndicator()));
    if (_hasError)
      return _buildCardContainer(
          borderColor: kPrimaryColor, child: _buildErrorMsg());
    if (_monthlyFlowData.isEmpty)
      return _buildCardContainer(
          borderColor: kPrimaryColor, child: _buildEmptyMsg());

    return _buildCardContainer(
      borderColor: kPrimaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fluxo Mensal',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kTextColor)),
          const SizedBox(height: 16),
          SizedBox(
            height: _secondaryChartHeight,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) =>
                            Colors.blueGrey.withOpacity(0.8))),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < _monthlyFlowData.length) {
                              return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                      _monthlyFlowData[index]['label']
                                          .toString(),
                                      style: const TextStyle(fontSize: 12)));
                            }
                            return const SizedBox();
                          })),
                  leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                      spots: List.generate(
                          _monthlyFlowData.length,
                          (index) => FlSpot(
                              index.toDouble(),
                              (_monthlyFlowData[index]['entradas'] as num)
                                  .toDouble())),
                      isCurved: true,
                      color: kSuccessColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false)),
                  LineChartBarData(
                      spots: List.generate(
                          _monthlyFlowData.length,
                          (index) => FlSpot(
                              index.toDouble(),
                              (_monthlyFlowData[index]['saidas'] as num)
                                  .toDouble())),
                      isCurved: true,
                      color: kDangerColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y,
      {Color color = kPrimaryColor}) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
          toY: y,
          width: 16,
          gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4), topRight: Radius.circular(4)))
    ]);
  }

  Widget _buildCategoryLegendItem(
      Color color, String label, String value, int index) {
    final isActive = _touchedCategoryIndex == index;
    return Row(children: [
      Container(
          width: isActive ? 16 : 14,
          height: isActive ? 16 : 14,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)]
                  : null)),
      const SizedBox(width: 12),
      Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: isActive ? 14 : 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? kTextColor : kTextColor.withOpacity(0.8)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1)),
      Text(value,
          style: TextStyle(
              fontSize: isActive ? 14 : 13,
              fontWeight: FontWeight.bold,
              color: kTextColor))
    ]);
  }
}
