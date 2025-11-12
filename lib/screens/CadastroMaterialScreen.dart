import 'package:flutter/material.dart';
import 'package:metro_projeto/services/inventory_service.dart';
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
  String? _selectedBase;
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
          'code': _codeController.text, ///estava comentado
          'category': _selectedCategory,
          'base': _selectedBase,
          'supplier': _supplierController.text,
          'validityType': _selectedValidityType,
          'minStock': _minStockController.text,
          'maxStock': _maxStockController.text,
          'description': _descriptionController.text,
          'validityDate' :_isDateRequired ? _dateController.text : null,

          //'location': _locationController.text,
        };

        try {
          final InventoryService = InventoryServices();
          await InventoryService.addItem(itemData);

          _showSnackBar('material cadastrado com sucesso!', isError: false);
          print('material enviado para o backend co sucesso');

          _restartScreen();
        } catch (e){
          print('ERRO NO ENVIO PARA O BACKEND: $e');
          _showSnackBar('falha ao cadastrar material.', isError: true);
        }

        //print(itemData);////////////////////////////////////RESOLVER PROBLEA QUE QUANDO CLICA NO BOTAO SALVAR APARECE COISAS DIFERENTES NO TERMINAL///////////////////////

      
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
            //////


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
                Expanded(child: _buildTextField(label: 'Fornecedor / Proprietario', controller: _supplierController)),
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
            Expanded(child: _buildDropdownField(
                  label: 'base', 
                  value: _selectedBase,
                  items: ['WJA (Jabaquara)', 'PSO (Paraiso)', 'TRD (Tiradentes)', 'TUC (Yucuruvi)', 'LUN (Luminarias)', 'IMG (Imigantes)', 'BFU (Barra Funda)', 'BAS (Brás)', 'CEC (Cecília)', 'MAT (Matheus)', 'VTD (Vila Matilde)', 'VPT (Vila Prudente)', 'PIT (Pátio Itaquera)', 'POT (Pátio Oratório)', 'PAT (Pátio Jabaquara)'],
                  onChanged: (value) => setState(() => _selectedBase = value),
                )),
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
                  label: 'estoque atual',
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






    // Construia(foi apagado) o card para upload da imagem e resumo ////TEM QUE TIRAR O CAMPO DE COLOCAR A IMAGEM!!!!!
   

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
      TextInputType keyboardType = TextInputType.text 
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
            validator: (value) { 
              if (value == null || value.isEmpty) {
                return 'Este campo é obrigatório.';
              }
              
              if (keyboardType == TextInputType.number && double.tryParse(value) == null) {
                return 'Insira um valor numérico válido.';
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
