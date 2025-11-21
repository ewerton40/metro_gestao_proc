import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import '../services/inventory_service.dart';
import '../utils/models/location.dart';
import 'inventory_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';


class MovimentacaoScreen extends StatefulWidget {
  const MovimentacaoScreen({super.key});

  @override
  State<MovimentacaoScreen> createState() => _MovimentacaoScreenState();
}

class _MovimentacaoScreenState extends State<MovimentacaoScreen>
    with TickerProviderStateMixin {
 
  String? _selectedDestino;
  String? _selectedMotivo;

  final _inventoryService = InventoryServices();

  final _entradaQtdController = TextEditingController();
  final _entradaObsController = TextEditingController();
  final _entradaDataController = TextEditingController();
  var dateMaskFormatter = MaskTextInputFormatter(
      mask: "##/##/####",
      filter: {"#": RegExp(r'[0-9]')});

  List<SimpleLocation> _locaisList = [];
  SimpleLocation? _selectedLocal;
  bool _isLoadingLocais = true;

  List<InventoryItem> _itemsList = [];
  InventoryItem? _selectedItem;
  bool _isLoadingItems = true;


  bool _isLoadingEntrada = false;


  final _saidaQtdController = TextEditingController();
  final _saidaObsController = TextEditingController();


  InventoryItem? _selectedSaidaItem;
  SimpleLocation? _selectedSaidaLocalOrigem;


  bool _isLoadingSaida = false;


  void _limparFormularioEntrada() {
    _entradaQtdController.clear();
    _entradaObsController.clear();
    setState(() {
      _selectedLocal = null;
      _selectedItem = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      _isLoadingLocais = true;
      _isLoadingItems = true;
    });

    try {
      final results = await Future.wait([
        _inventoryService.getAllLocations(),
        _inventoryService.getAllItems(),
      ]);

      setState(() {
        _locaisList = results[0] as List<SimpleLocation>;
        _isLoadingLocais = false;

        _itemsList = results[1] as List<InventoryItem>;
        _isLoadingItems = false;
      });
    } catch (e) {
      print("Erro ao carregar dados dos dropdowns: $e");
      setState(() {
        _isLoadingLocais = false;
        _isLoadingItems = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red),
      );
    }
  }


  Future<void> _salvarSaida() async {

    setState(() => _isLoadingSaida = true);

    try {
      final authService = context.read<AuthServices>();

      if (_selectedSaidaItem == null ||
          _saidaQtdController.text.isEmpty ||
          _selectedSaidaLocalOrigem == null) {
        throw Exception(
            'Preencha todos os campos obrigatórios (Item, Qtd, Origem).');
      }

      if (!authService.estaLogado || authService.usuario == null) {
        throw Exception(
            'Erro: Usuário não está logado. Faça o login novamente.');
      }
 
      final int idMaterial = _selectedSaidaItem!.code;
      final int quantidade = int.parse(_saidaQtdController.text);
      final int idLocalOrigem = _selectedSaidaLocalOrigem!.id;
 
      final int idFuncionario = authService.usuario!.id;
      final String observacao = _saidaObsController.text;

  
      final response = await _inventoryService.registerSaida(
        idMaterial: idMaterial,
        quantidade: quantidade,
        idLocalOrigem: idLocalOrigem,
        idFuncionario: idFuncionario,
        observacao: observacao,
      );

      if (response['success'] == true) {
        _limparFormularioSaida();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Saída registrada com sucesso!'),
              backgroundColor: Colors.green),
        );
      } else {
   
        throw Exception(response['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoadingSaida = false);
  }

  
  Future<void> _salvarEntrada() async {
   
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Lógica de _salvarEntrada não implementada.'),
          backgroundColor: Colors.orange),
    );
  }


  void _limparFormularioSaida() {
    _saidaQtdController.clear();
    _saidaObsController.clear();
    setState(() {
      _selectedSaidaItem = null;
      _selectedSaidaLocalOrigem = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const BarMenu(),
        drawer: const VerticalMenu(selectedIndex: 2),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Movimentações',
                style: theme.textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF082583),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  tabs: const [
                    Tab(text: 'Registrar Entrada'),
                    Tab(text: 'Registrar Saída'),
                  ],
                  labelStyle: theme.textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelColor: theme.colorScheme.onPrimaryContainer,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue.shade100,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
              ),

              const SizedBox(height: 24),

              // Conteúdo das Abas
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TabBarView(
                    children: [
                      _buildEntradaForm(theme),
                      _buildSaidaForm(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildEntradaForm(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registrar Entrada',
              style: theme.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          _buildItemDropdown(theme),
          const SizedBox(height: 16),

          _buildFormTextField(
              theme: theme,
              label: 'Quantidade',
              controller: _entradaQtdController,
              keyboardType: TextInputType.number),
          const SizedBox(height: 16),

          _buildLocalDropdown(theme),
          const SizedBox(height: 16),

          _buildDateField(theme),
          const SizedBox(height: 16),

          _buildFormTextField(
              theme: theme,
              label: 'Observações',
              controller: _entradaObsController,
              maxLines: 3),
          const SizedBox(height: 24),

  
          _isLoadingEntrada
              ? const Center(child: CircularProgressIndicator())
              : _buildFormButtons(
                  theme: theme,
                  primaryText: 'Salvar Entrada',
                  onPrimaryPressed: _salvarEntrada,
                  onCancelPressed: _limparFormularioEntrada),
        ],
      ),
    );
  }


  Widget _buildSaidaForm(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registrar Saída',
              style: theme.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          _buildSaidaItemDropdown(theme),
          const SizedBox(height: 16),

          _buildFormTextField(
              theme: theme,
              label: 'Quantidade',
              controller: _saidaQtdController,
              keyboardType: TextInputType.number),
          const SizedBox(height: 16),

          _buildSaidaLocalOrigemDropdown(theme),
          const SizedBox(height: 16),

          _buildFormTextField(
              theme: theme,
              label: 'Observações',
              controller: _saidaObsController,
              maxLines: 3),
          const SizedBox(height: 24),

        
          _isLoadingSaida
              ? const Center(child: CircularProgressIndicator())
              : _buildFormButtons(
                  theme: theme,
                  primaryText: 'Salvar Saída',
                  onPrimaryPressed: _salvarSaida,
                  onCancelPressed: _limparFormularioSaida),
        ],
      ),
    );
  }

 
  Widget _buildFormTextField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor:
                Colors.white, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }


  Widget _buildLocalDropdown(ThemeData theme) {
    if (_isLoadingLocais) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Base de destino',
            style: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        DropdownButtonFormField<SimpleLocation>(
          isExpanded: true,
          value: _selectedLocal,
          hint: const Text('Selecione uma base de destino'),
          items: _locaisList.map((SimpleLocation local) {
            return DropdownMenuItem<SimpleLocation>(
              value: local,
              child: Text(local.nome),
            );
          }).toList(),
          onChanged: (SimpleLocation? newValue) {
            setState(() {
              _selectedLocal = newValue;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor:
                Colors.white, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) => value == null ? 'Campo obrigatório' : null,
        ),
      ],
    );
  }

  Widget _buildItemDropdown(ThemeData theme) {
    if (_isLoadingItems) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: LinearProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item',
            style: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        DropdownButtonFormField<InventoryItem>(
          isExpanded: true,
          value: _selectedItem,
          hint: const Text('Selecione um item'),
          items: _itemsList.map((InventoryItem item) {
            return DropdownMenuItem<InventoryItem>(
              value: item,
              child: Text(item.nome),
            );
          }).toList(),
          onChanged: (InventoryItem? newValue) {
            setState(() {
              _selectedItem = newValue;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor:
                Colors.white, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
         
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) => value == null ? 'Campo obrigatório' : null,
        ),
      ],
    );
  }


  Widget _buildDateField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data da Entrada',
            style: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _entradaDataController,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [
            dateMaskFormatter,
          ],
          decoration: InputDecoration(
            hintText: 'DD/MM/AAAA',
            suffixIcon: Icon(Icons.calendar_today_outlined,
                color: theme.colorScheme.primary),
            counterText: '',
            filled: true,
            fillColor:
                Colors.white, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 10) {
              return "A data deve estar completa (DD/MM/AAAA)";
            }
            return null;
          },
        ),
      ],
    );
  }


  Widget _buildSaidaItemDropdown(ThemeData theme) {
    if (_isLoadingItems) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: LinearProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Item',
            style: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        DropdownButtonFormField<InventoryItem>(
          isExpanded: true,
          value: _selectedSaidaItem,
          hint: const Text('Selecione um item'),
          items: _itemsList.map((InventoryItem item) {
            return DropdownMenuItem<InventoryItem>(
              value: item,
              child: Text(item.nome),
            );
          }).toList(),
          onChanged: (InventoryItem? newValue) {
            setState(() {
              _selectedSaidaItem = newValue;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor:
                Colors.white, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }


  Widget _buildSaidaLocalOrigemDropdown(ThemeData theme) {
    if (_isLoadingLocais) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Local de Origem',
            style: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        DropdownButtonFormField<SimpleLocation>(
          isExpanded: true,
          value: _selectedSaidaLocalOrigem,
          hint: const Text('Selecione o local de origem'),
          items: _locaisList.map((SimpleLocation local) {
            return DropdownMenuItem<SimpleLocation>(
              value: local,
              child: Text(local.nome),
            );
          }).toList(),
          onChanged: (SimpleLocation? newValue) {
            setState(() {
              _selectedSaidaLocalOrigem = newValue;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor:
                Colors.white, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFormButtons({
    required ThemeData theme,
    required String primaryText,
    required VoidCallback onPrimaryPressed,
    VoidCallback? onCancelPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancelPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              side: BorderSide(color: Colors.blue.shade700),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onPrimaryPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: Text(primaryText),
          ),
        ),
      ],
    );
  }
}