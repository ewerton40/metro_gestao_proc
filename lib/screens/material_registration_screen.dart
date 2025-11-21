
import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/services/inventory_service.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../utils/models/location.dart';
import 'inventory_screen.dart'; 

class MaterialRegistrationScreen extends StatefulWidget {
  const MaterialRegistrationScreen({super.key});

  @override
  State<MaterialRegistrationScreen> createState() => MaterialRegistrationScreenState();
}

class MaterialRegistrationScreenState extends State<MaterialRegistrationScreen  > {
  final _formKey = GlobalKey<FormState>();

  // Variáveis de Estado para os Dropdowns
  String? _selectedCategory;
  String? _selectedBase;
  String? _selectedValidityType;

  // Listas dinâmicas vindas do Backend
  final _inventoryService = InventoryServices();
  List<Category> _categoriesList = [];
  List<SimpleLocation> _basesList = [];
  bool _isLoadingData = true;

  // Mapa de validação de códigos (Atenção: os nomes das chaves devem bater com o nome da categoria no banco)
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
    _loadDropdownData(); // Busca os dados ao iniciar
  }

  // Busca categorias e bases do backend
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
      // Encontra o ID da categoria selecionada
      // (Se não achar, usa 0, mas a validação deve impedir isso)
      int categoryId = 0;
      try {
        categoryId = _categoriesList
            .firstWhere((cat) => cat.nome == _selectedCategory)
            .id;
      } catch (e) {
        print("Categoria não encontrada na lista: $_selectedCategory");
      }

      // Cria o objeto InventoryItem para enviar ao serviço
      final newItem = InventoryItem(
        code: int.tryParse(_codeController.text) ?? 0,
        nome: _nameController.text,

        categoriaId: categoryId,
        categoriaNome: _selectedCategory ?? '',

        // TODO: Adicionar campo de "Medida" no formulário futuramente
        medidaId: 1, // Valor padrão temporário (ex: UN)
        medidaNome: 'UN',

        calibracao:
            _isDateRequired, // Usa a lógica da data para definir se requer calibração
        qtdAlto: int.tryParse(_maxStockController.text) ?? 0,
        qtdBaixo: int.tryParse(_minStockController.text) ?? 0,
        descricao: _descriptionController.text,
        quantidadeAtual: 0,
      );

      try {
        await _inventoryService.addItem(newItem);

        _showSnackBar('Material cadastrado com sucesso!', isError: false);

        // Espera um pouco antes de recarregar para o usuário ver a mensagem
        await Future.delayed(const Duration(seconds: 1));
        _restartScreen();
      } catch (e) {
        final String fullError = e.toString();
        final String errorMessage = fullError.contains('Exception:')
            ? fullError.substring(11)
            : 'Falha desconhecida no cadastro';

        print('ERRO NO ENVIO PARA O BACKEND: $e');
        _showSnackBar(errorMessage, isError: true);
      }
    }
  }

void _restartScreen() {

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const MaterialRegistrationScreen(),
    ),
  );
}
/////////////////////////mostra falah ao cadastrar material
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cadastro de materiais',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildFormCard(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24.0),
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

            // Campo de Código com Validação de Faixa
            _buildTextField(
              label: 'Código do Item',
              controller: _codeController,
              keyboardType: TextInputType.number,
              customValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo é obrigatório.';
                }
                final codeNumber = int.tryParse(value);

                if (codeNumber == null) {
                  return 'Insira apenas números inteiros para o código.';
                }

                final selectedCategory = _selectedCategory;
                if (selectedCategory != null &&
                    _codeRanges.containsKey(selectedCategory)) {
                  final range = _codeRanges[selectedCategory]!;
                  if (codeNumber < range.min || codeNumber > range.max) {
                    final minStr = range.min.toString();
                    final maxStr = range.max.toString();
                    return 'O código deve estar entre $minStr e $maxStr para a categoria "$selectedCategory".';
                  }
                }
                // Removemos o erro se a categoria for nula para não travar o formulário antes da hora,
                // o validador do dropdown de categoria cuidará disso.
                return null;
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                // === DROPDOWN DE CATEGORIA (DINÂMICO) ===
                Expanded(
                    child: _isLoadingData
                        ? const Center(child: LinearProgressIndicator())
                        : _buildDropdownField(
                            label: 'Categoria',
                            value: _selectedCategory,
                            // Mapeia a lista de objetos Category para Strings
                            items:
                                _categoriesList.map((cat) => cat.nome).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedCategory = value),
                            hint: 'Selecione a Categoria',
                          )),

                const SizedBox(width: 16),
                Expanded(
                    child: _buildTextField(
                        label: 'Fornecedor / Proprietário',
                        controller: _supplierController)),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                    child: _buildDropdownField(
                  label: 'Tipo de validade',
                  value: _selectedValidityType,
                  items: [
                    'Tem validade ou calibração',
                    'Não tem validade nem calibração'
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedValidityType = value;
                      // Ajuste simples para ignorar case sensitive se necessário
                      _isDateRequired = (value == 'Tem validade ou calibração');
                      if (!_isDateRequired) {
                        _dateController.clear();
                      }
                    });
                  },
                  hint: 'Selecione o tipo',
                )),

                const SizedBox(width: 16),

                // === DROPDOWN DE BASE (DINÂMICO) ===
                Expanded(
                    child: _isLoadingData
                        ? const Center(child: LinearProgressIndicator())
                        : _buildDropdownField(
                            label: 'Base',
                            value: _selectedBase,
                            // Mapeia a lista de objetos SimpleLocation para Strings
                            items: _basesList.map((loc) => loc.nome).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedBase = value),
                            hint: 'Selecione a Base',
                          )),
              ],
            ),

            const SizedBox(height: 16),

            Row(children: [
              if (_isDateRequired)
                Expanded(
                  flex: 2,
                  child: _buildDateField(),
                ),
              if (_isDateRequired) const SizedBox(width: 16),
              if (!_isDateRequired)
                const Expanded(flex: 2, child: SizedBox.shrink()),
              Expanded(
                  flex: 1,
                  child: _buildTextField(
                    label: 'Estoque baixo',
                    controller: _minStockController,
                    keyboardType: TextInputType.number,
                  )),
              const SizedBox(width: 16),
              Expanded(
                  flex: 1,
                  child: _buildTextField(
                    label:
                        'Estoque alto', // Ajustado label para bater com a lógica (maxStock)
                    controller: _maxStockController,
                    keyboardType: TextInputType.number,
                  )),
            ]),

            const SizedBox(height: 16),
            _buildTextField(
                label: 'Descrição',
                controller: _descriptionController,
                maxLines: 3),
            const SizedBox(height: 24),

            Row(
              children: [
                ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1763A6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

   
    Widget _buildDateField(){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(' vencimento/calibração', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _dateController,
            
            keyboardType: TextInputType.number,
            maxLength: 10,
            inputFormatters: [
              dateMaskFormatter,
            ],

              decoration: InputDecoration(
              hintText: 'DD/MM/AAAA',
              suffixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.black54),
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!),            
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) {
            
              if (_isDateRequired && (value == null || value.isEmpty)) {
                return 'Obrigatório selecionar a data.';
              }
              if (_isDateRequired && value != null && value.length < 10 ){
                return "A data deve estar completa (DD/MM/AAAA)";
              }
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
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
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: customValidator ?? (value) { 
              if (value == null || value.isEmpty) {
                return 'Este campo é obrigatório.';
              }
              if (keyboardType == TextInputType.number && int.tryParse(value) == null) {
                return 'Insira um valor numérico inteiro válido.';
              }
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
    }) 
      {
      if(value != null && !items.contains(value)){
        value = null;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
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
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) { 
              if (value == null || value.isEmpty) {
                return 'Selecione uma opção.';
              }
              return null;
            },
          ),
        ],
      );
    }
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Text(value),
        ),
      ],
    );
  }

