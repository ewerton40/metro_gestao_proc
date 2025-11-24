import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/services/inventory_service.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import 'package:provider/provider.dart';
import 'package:metro_projeto/providers/user_provider.dart';
import 'package:metro_projeto/screens/dashboard_screen.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import '../utils/models/location.dart';
import 'inventory_screen.dart';


const Color primaryColor = Color(0xFF1976D2); 
const Color accentColor = Color(0xFF42A5F5); 
const Color backgroundColor = Color(0xFFF4F6F8); 
const Color cardColor = Colors.white; 
const Color textColor = Color(0xFF212121); 
const Color hintColor = Color(0xFF757575); 

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
        lastDate: DateTime(2101),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: primaryColor, 
                onPrimary: Colors.white,
                surface: cardColor,
                onSurface: textColor,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
            ),
            child: child!,
          );
        });
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
    final userProvider = Provider.of<UserProvider>(context);

    if (!userProvider.isAdmin) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: const BarMenu(),
        drawer: const VerticalMenu(selectedIndex: 5),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'Acesso negado. Você não tem permissão para acessar esta área.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  child: const Text('Voltar ao Painel'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor, 
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
                    'Cadastro de Materiais', 
                    style: TextStyle(
                        fontSize: isMobile ? 28 : 30, 
                        fontWeight: FontWeight.w800, 
                        color: const Color(0xFF082583)),
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
        padding: EdgeInsets.all(isMobile ? 24.0 : 32.0), 
        decoration: BoxDecoration(
          color: cardColor, 
          borderRadius: BorderRadius.circular(16), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 5), 
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         
            _buildTextField(label: 'Nome do Item', controller: _nameController),
            const SizedBox(height: 24), 
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
            const SizedBox(height: 24),
            
          
            _buildResponsiveRow(
              isMobile: isMobile,
              children: [
                _isLoadingData
                    ? const Center(child: LinearProgressIndicator(color: primaryColor))
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
            const SizedBox(height: 24),
            
           
            _buildResponsiveRow(
              isMobile: isMobile,
              children: [
                _buildDropdownField(
                  label: 'Tipo de validade',
                  value: _selectedValidityType,
                  items: const [
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
                    ? const Center(child: LinearProgressIndicator(color: primaryColor))
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
            const SizedBox(height: 24),
            
           
            _buildResponsiveRow(
              isMobile: isMobile,
              children: [
                if (_isDateRequired)
                  _buildDateField()
                else
                  const SizedBox.shrink(),
                
          
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Controle de Estoque', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textColor)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                          label: 'Estoque baixo',
                          controller: _minStockController,
                          keyboardType: TextInputType.number,
                          isInlineLabel: true,
                        )),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildTextField(
                          label: 'Estoque alto',
                          controller: _maxStockController,
                          keyboardType: TextInputType.number,
                          isInlineLabel: true,
                        )),
                      ],
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            
     
            _buildTextField(
                label: 'Descrição',
                controller: _descriptionController,
                maxLines: 4), 
            const SizedBox(height: 32),
            
 
            SizedBox(
              width: isMobile ? double.infinity : 250,
              child: ElevatedButton(
                onPressed: _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 18), 
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)), 
                  elevation: 5, 
                ),
                child: const Text(
                  'Salvar Material',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _buildResponsiveRow(
      {required bool isMobile, required List<Widget> children}) {
    
    if (isMobile) {
      return Column(
        children: [
          children[0],
          const SizedBox(height: 24), 
          children[1],
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: children[0]),
          const SizedBox(width: 24),
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
            style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
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
                  color: primaryColor), 
              onPressed: () => _selectDate(context),
            ),
            counterText: '',
            filled: true,
            fillColor: backgroundColor, 
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none), 
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryColor, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
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
    bool isInlineLabel = false, 
  }) {

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: backgroundColor, 
      hintText: isInlineLabel ? label : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none), 
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2)), 
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
    );

    if (isInlineLabel) {
   
      return TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: inputDecoration,
        validator: customValidator ??
            (value) {
              if (value == null || value.isEmpty)
                return 'Obrigatório.';
              if (keyboardType == TextInputType.number &&
                  int.tryParse(value) == null)
                return 'Número inválido.';
              return null;
            },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: textColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: inputDecoration,
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
    required String hint,
  }) {
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: textColor)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroundColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryColor, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          hint: Text(hint, style: TextStyle(color: hintColor)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: primaryColor),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: textColor)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Este campo é obrigatório.';
            return null;
          },
        ),
      ],
    );
  }
}
