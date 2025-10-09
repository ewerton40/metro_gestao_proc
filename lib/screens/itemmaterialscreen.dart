import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';

class ItemRegistrationScreen extends StatefulWidget {
  const ItemRegistrationScreen({super.key});

  @override
  State<ItemRegistrationScreen> createState() => _ItemRegistrationScreenState();
}

class _ItemRegistrationScreenState extends State<ItemRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory = 'Equipamentos';
  String? _selectedValidityType;

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _supplierController = TextEditingController();
  final _locationController = TextEditingController();
  final _minStockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxStockcontroller = TextEditingController();
  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _supplierController.dispose();
    _locationController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    _maxStockcontroller.dispose();
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
          'maxStock': _maxStockcontroller,
          'description': _descriptionController.text,
        };
      }
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
      return Container(
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
                  items: ['Equipamentos', 'Ferramentas', 'Peças'],
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  hint: 'Equipamentos',
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
                  onChanged: (value) => setState(() => _selectedValidityType = value),
                  
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(label: 'Localização Física', controller: _locationController)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(flex: 1, child: Container(),),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: Container(),),
                
                const SizedBox(width: 16,),
                Expanded(flex: 1, child:_buildTextField(
                  label: 'Estoque baixo',
                  controller: _minStockController
                )
              ),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: _buildTextField(
                  label: 'estoque alto',
                  controller: _maxStockcontroller
                )
              ),
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
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[400]!),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Voltar'),
                ),
              ],
            )
          ],
        ),
      );
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
            _buildReadOnlyField(label: 'Categoria', value: 'Equipamentos'),
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

    // Widget auxiliar para criar campos de texto padrão
    Widget _buildTextField({required String label, required TextEditingController controller, int maxLines = 1}) {////////////////////////////////////////
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
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
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
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
