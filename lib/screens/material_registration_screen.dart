import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/services/inventory_service.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import '../utils/models/location.dart';
import 'inventory_screen.dart';

class MaterialRegistrationScreen extends StatefulWidget {
  const MaterialRegistrationScreen({super.key});

  @override
  State<MaterialRegistrationScreen> createState() =>
      _MaterialRegistrationScreenState();
}

class _MaterialRegistrationScreenState
    extends State<MaterialRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  String? _selectedBase;
  String? _selectedValidityType;

  final _inventoryService = InventoryServices();
  List<Category> _categoriesList = [];
  List<SimpleLocation> _basesList = [];
  bool _isLoadingData = true;

  final Map<String, ({int min, int max})> _codeRanges = {
    'Material de consumo': (min: 10000000, max: 10999999),
    'Material de Giro': (min: 15000000, max: 15999999),
    'Material Patrimoniado': (min: 16000000, max: 16999999),
    'Ferramentas Manuais': (min: 17000000, max: 17999999),
    'Debito Direto': (min: 20000000, max: 20999999),
    'material sobressalente': (min: 21000000, max: 21999999),
  };

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _supplierController = TextEditingController();
  final _minStockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxStockController = TextEditingController();

  var dateMaskFormatter = MaskTextInputFormatter(
      mask: "##/##/####", filter: {"#": RegExp(r'[0-9]')});

  final _dateController = TextEditingController();
  bool _isDateRequired = false;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final results = await Future.wait([
        _inventoryService.getAllCategories(),
        _inventoryService.getAllLocations(),
      ]);

      setState(() {
        _categoriesList = results[0] as List<Category>;
        _basesList = results[1] as List<SimpleLocation>;
        _isLoadingData = false;
      });
    } catch (e) {
      print('Erro ao carregar dropdowns: $e');
      _showSnackBar('Erro ao carregar dados do servidor', isError: true);
      setState(() => _isLoadingData = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _supplierController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    _maxStockController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      int categoryId = 0;
      try {
        categoryId = _categoriesList
            .firstWhere((cat) => cat.nome == _selectedCategory)
            .id;
      } catch (e) {
        print("Categoria não encontrada na lista: $_selectedCategory");
      }

      final newItem = InventoryItem(
        code: int.tryParse(_codeController.text) ?? 0,
        nome: _nameController.text,
        categoriaId: categoryId,
        categoriaNome: _selectedCategory ?? '',
        medidaId: 1,
        medidaNome: 'UN',
        calibracao: _isDateRequired,
        qtdAlto: int.tryParse(_maxStockController.text) ?? 0,
        qtdBaixo: int.tryParse(_minStockController.text) ?? 0,
        descricao: _descriptionController.text,
        quantidadeAtual: 0,
      );

      try {
        await _inventoryService.addItem(newItem);
        _showSnackBar('Material cadastrado com sucesso!', isError: false);
        await Future.delayed(const Duration(seconds: 1));
        _restartScreen();
      } catch (e) {
        final String fullError = e.toString();
        final String errorMessage = fullError.contains('Exception:')
            ? fullError.substring(11)
            : 'Falha desconhecida no cadastro';
        _showSnackBar(errorMessage, isError: true);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null) {
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      _dateController.text = formatter.format(picked);
    }
  }

  void _restartScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MaterialRegistrationScreen(),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BarMenu(),
      drawer: const VerticalMenu(selectedIndex: 5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 800;
          double horizontalPadding = isMobile ? 16.0 : 48.0;
          double verticalPadding = isMobile ? 24.0 : 32.0;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: verticalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cadastro de materiais',
                    style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _buildFormCard(isMobile),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(bool isMobile) {
    return Form(
      key: _formKey,
      child: Container(
        width: isMobile ? double.infinity : 1000,
        padding: EdgeInsets.all(isMobile ? 20.0 : 24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(label: 'Nome do Item', controller: _nameController),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Código do Item',
              controller: _codeController,
              keyboardType: TextInputType.number,
              customValidator: (value) {
                if (value == null || value.isEmpty)
                  return 'Este campo é obrigatório.';
                final codeNumber = int.tryParse(value);
                if (codeNumber == null)
                  return 'Insira apenas números inteiros.';
                final selectedCategory = _selectedCategory;
                if (selectedCategory != null &&
                    _codeRanges.containsKey(selectedCategory)) {
                  final range = _codeRanges[selectedCategory]!;
                  if (codeNumber < range.min || codeNumber > range.max) {
                    return 'O código deve estar entre ${range.min} e ${range.max} para "$selectedCategory".';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildResponsiveRow(
              isMobile: isMobile,
              children: [
                _isLoadingData
                    ? const Center(child: LinearProgressIndicator())
                    : _buildDropdownField(
                        label: 'Categoria',
                        value: _selectedCategory,
                        items: _categoriesList.map((cat) => cat.nome).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value),
                        hint: 'Selecione a Categoria',
                      ),
                _buildTextField(
                    label: 'Fornecedor / Proprietário',
                    controller: _supplierController),
              ],
            ),
            const SizedBox(height: 16),
            _buildResponsiveRow(
              isMobile: isMobile,
              children: [
                _buildDropdownField(
                  label: 'Tipo de validade',
                  value: _selectedValidityType,
                  items: [
                    'Tem validade ou calibração',
                    'Não tem validade nem calibração'
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedValidityType = value;
                      _isDateRequired = (value == 'Tem validade ou calibração');
                      if (!_isDateRequired) _dateController.clear();
                    });
                  },
                  hint: 'Selecione o tipo',
                ),
                _isLoadingData
                    ? const Center(child: LinearProgressIndicator())
                    : _buildDropdownField(
                        label: 'Base',
                        value: _selectedBase,
                        items: _basesList.map((loc) => loc.nome).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedBase = value),
                        hint: 'Selecione a Base',
                      ),
              ],
            ),
            const SizedBox(height: 16),
            _buildResponsiveRow(
              isMobile: isMobile,
              children: [
                if (_isDateRequired)
                  _buildDateField()
                else
                  const SizedBox.shrink(),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                      label: 'Estoque baixo',
                      controller: _minStockController,
                      keyboardType: TextInputType.number,
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(
                      label: 'Estoque alto',
                      controller: _maxStockController,
                      keyboardType: TextInputType.number,
                    )),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
                label: 'Descrição',
                controller: _descriptionController,
                maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: isMobile ? double.infinity : null,
              child: ElevatedButton(
                onPressed: _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1763A6),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Salvar'),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para responsividade
  Widget _buildResponsiveRow(
      {required bool isMobile, required List<Widget> children}) {
    if (isMobile) {
      return Column(
        children: [
          children[0],
          const SizedBox(height: 16),
          children[1],
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: children[0]),
          const SizedBox(width: 16),
          Expanded(child: children[1]),
        ],
      );
    }
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vencimento / Calibração',
            style:
                TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [dateMaskFormatter],
          decoration: InputDecoration(
            hintText: 'DD/MM/AAAA',
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today_outlined,
                  color: Colors.black54),
              onPressed: () => _selectDate(context),
            ),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (_isDateRequired && (value == null || value.isEmpty))
              return 'Obrigatório selecionar a data.';
            if (_isDateRequired && value != null && value.length < 10)
              return "Data incompleta";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? customValidator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: customValidator ??
              (value) {
                if (value == null || value.isEmpty)
                  return 'Este campo é obrigatório.';
                if (keyboardType == TextInputType.number &&
                    int.tryParse(value) == null)
                  return 'Insira um número válido.';
                return null;
              },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String hint = '',
  }) {
    if (value != null && !items.contains(value)) value = null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Selecione uma opção.' : null,
        ),
      ],
    );
  }
}
