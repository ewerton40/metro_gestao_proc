import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroMaterialScreen extends StatefulWidget {
  const CadastroMaterialScreen({super.key});

  @override
  State<CadastroMaterialScreen> createState() => CadastroMaterialScreenState();
}

class CadastroMaterialScreenState extends State<CadastroMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory = 'Equipamentos';
  String? _selectedValidityType;

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _supplierController = TextEditingController();
  final _locationController = TextEditingController();
  final _minStockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxStockController = TextEditingController();

  var dateMaskFormatter = MaskTextInputFormatter(
    mask: "##/##/####", // Define o formato DD/MM/AAAA
    filter: { "#": RegExp(r'[0-9]') } // Permite apenas dígitos (números)
  );

  final _dateController = TextEditingController();
  bool _isDateRequired = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _supplierController.dispose();
    _locationController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    _maxStockController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
      // Coleta dos dados dos controladores e variáveis de estado
      if (_formKey.currentState!.validate()) {
        final itemData = {
          'name': _nameController.text,
          'code': _codeController.text,
          'category': _selectedCategory,
          'supplier': _supplierController.text,
          'validityType': _selectedValidityType,
          'location': _locationController.text,
          'minStock': _minStockController.text,
          'maxStock': _maxStockController.text,
          'description': _descriptionController.text,
          'validityDate' :_isDateRequired ? _dateController.text : null,
        };
        print(itemData);////////////////////////////////////RESOLVER PROBLEA QUE QUANDO CLICA NO BOTAO SALVAR APARECE COISAS DIFERENTES NO TERMINAL///////////////////////

        _restartScreen();
      }
  }

  Future<void> _selectDate(BuildContext context) async { //funcao para abrir o datepicker
    FocusScope.of(context).requestFocus(FocusNode()); //esvita que o teclado abra

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101) //pesquisar o que é esse 2101
    );

    if (picked != null) {
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      _dateController.text = formatter.format(picked);
    }
  }

void _restartScreen() {

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const CadastroMaterialScreen(),
    ),
  );
}
    @override
    Widget build(BuildContext context) {
      // A tela principal é envolvida por um Scaffold para a estrutura básica.
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          
          title: Image.asset( //////////////////////////////////////////////
            'assets/images/logo_metro_menu.png',
            width: 40.0,
            height: 40.0,
          ),
          actions: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person_outline, color: Colors.black54),
            ),
            const SizedBox(width: 16),
          ],
        ),
        drawer: const VerticalMenu(), ////////////////////////////////////////////////////

        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cadastro de materiais',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2, // A coluna do formulário ocupa 2/3 do espaço
                      child: _buildFormCard(),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 1, // A coluna da imagem ocupa 1/3 do espaço
                      child: _buildImageUploadCard(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Constrói o card principal do formulário
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
            _buildTextField(label: 'Código do Item', controller: _codeController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdownField(
                  label: 'Categoria',
                  value: _selectedCategory,
                  items: ['Material de consumo', 'Material de Giro', 'Material Patrimoniado', 'Ferramentas Manuais','Debito Direto', 'material sobressalente'],
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  hint: 'Materiais',
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(label: 'Fornecedor', controller: _supplierController)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdownField(
                  label: 'tipo de validade',
                  value: _selectedValidityType,
                  items: ['tem validade ou calibração', 'não tem validade nem calibração'],
                  onChanged: (value) { 
                    setState(() { 
                      _selectedValidityType = value;
                      _isDateRequired = (value == 'tem validade ou calibração');
                      if (!_isDateRequired) {
                        _dateController.clear();
                      }
                    });
                  },
                )),

                const SizedBox(width: 16),
                Expanded(child: _buildTextField(label: 'Localização Física', controller: _locationController)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_isDateRequired)
                  Expanded(
                    flex: 2,
                    child: _buildDateField(),
                  ),
                
                if (_isDateRequired) const SizedBox(width: 16),

                if (!_isDateRequired)
                  const Expanded(flex: 2, child: SizedBox.shrink()),

                Expanded(flex: 1, child:_buildTextField(
                  label: 'Estoque baixo',
                  controller: _minStockController,
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 16),

                Expanded(flex: 1, child: _buildTextField(
                  label: 'estoque alto',
                  controller: _maxStockController,
                  keyboardType: TextInputType.number,
                )),
              ]
            ),
            const SizedBox(height: 16),
            _buildTextField(label: 'Descrição', controller: _descriptionController, maxLines: 3),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton(
                  onPressed:_saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1763A6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            )
          ],
        ),
      ),
    );////////// ) do form
  }






    // Constrói o card para upload da imagem e resumo
    Widget _buildImageUploadCard() {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image_outlined, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildReadOnlyField(label: 'Categoria', value: 'materiais'),
            const SizedBox(height: 16),
            _buildReadOnlyField(label: 'Estoque Mínimo', value: '5'),
            const SizedBox(height: 24),
            TextButton.icon(
              icon: const Icon(Icons.attach_file, color: Color(0xFF1763A6)),
              label: const Text('Upload de Foto', style: TextStyle(color: Color(0xFF1763A6))),
              onPressed: () {},
            ),
          ],
        ),
      );
    }

    Widget _buildDateField(){ /////// criado, nao tinha antes
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
            // O campo é obrigatório APENAS se _isDateRequired for true
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


    // Widget auxiliar para criar campos de texto padrão
    Widget _buildTextField({
      required String label, 
      required TextEditingController controller, 
      int maxLines = 1,
      TextInputType keyboardType = TextInputType.text 
    }) {////////////////////////////////////////

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
            validator: (value) { // <<< ALTERADA: Adicionada validação básica
              if (value == null || value.isEmpty) {
                return 'Este campo é obrigatório.';
              }
              // Validação simples para campos numéricos
              if (keyboardType == TextInputType.number && double.tryParse(value) == null) {
                return 'Insira um valor numérico válido.';
              }
              return null;
            },
          ),
        ],
      );
    }
    
    // Widget auxiliar para criar campos de dropdown
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
            validator: (value) { // <<< ADICIONADA: Validação para Dropdown
              if (value == null || value.isEmpty) {
                return 'Selecione uma opção.';
              }
              return null;
            },
          ),
        ],
      );
    }
    
    // Widget auxiliar para campos de texto somente leitura
    Widget _buildReadOnlyField({required String label, required String value}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
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
  }
