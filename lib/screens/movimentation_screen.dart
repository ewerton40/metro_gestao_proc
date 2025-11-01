import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';

class MovimentacaoScreen extends StatefulWidget {
  const MovimentacaoScreen({super.key});

  @override
  State<MovimentacaoScreen> createState() => _MovimentacaoScreenState();
}

class _MovimentacaoScreenState extends State<MovimentacaoScreen> with TickerProviderStateMixin {
  
  // Variáveis de estado para os dropdowns do formulário de Saída
  String? _selectedDestino;
  String? _selectedMotivo;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), 
        appBar: const BarMenu(),
        drawer: const VerticalMenu(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Movimentações',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 24),

              // Abas para "Registrar Entrada" e "Registrar Saída"
              TabBar(
                tabs: const [
                  Tab(text: 'Registrar Entrada'),
                  Tab(text: 'Registrar Saída'),
                ],
                labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.grey[600],
                labelColor: const Color(0xFF1763A6),
                indicatorColor: const Color(0xFF1763A6),
                indicatorWeight: 3,
              ),
              
              const SizedBox(height: 24),

              // Conteúdo das Abas
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TabBarView(
                    children: [
                      _buildEntradaForm(),
                      _buildSaidaForm(),
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

  /// Constrói o formulário de "Registrar Entrada"
  Widget _buildEntradaForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registrar Entrada', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildFormTextFieldWithIcon(label: 'Item', icon: Icons.search),
          const SizedBox(height: 16),
          _buildFormSelectionField(label: 'Quantidade'),
          const SizedBox(height: 16),
          _buildFormSelectionField(label: 'Base de destino'),
          const SizedBox(height: 16),
          _buildFormTextFieldWithIcon(label: 'Data de entrada', icon: Icons.calendar_today_outlined),
          const SizedBox(height: 16),
          _buildFormTextField(label: 'Responsável'),
          const SizedBox(height: 16),
          _buildFormTextField(label: 'Observações', maxLines: 3),
          const SizedBox(height: 24),
          _buildFormButtons(primaryText: 'Salvar Entrada', onPrimaryPressed: () {}),
        ],
      ),
    );
  }

  /// Constrói o formulário de "Registrar Saída"
  Widget _buildSaidaForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registrar Saída', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildFormTextFieldWithIcon(label: 'Item', icon: Icons.search),
          const SizedBox(height: 16),
          _buildFormTextField(label: 'Quantidade'), 
          const SizedBox(height: 16),
          // Dropdown para Destino
          _buildFormDropdownField(
            label: 'Destino',
            value: _selectedDestino,
            items: ['Base Jabaquara', 'Base Paraíso', 'Oficina Central'],
            onChanged: (value) => setState(() => _selectedDestino = value),
          ),
          const SizedBox(height: 16),
          // Dropdown para Motivo 
          _buildFormDropdownField(
            label: 'Motivo da saída',
            value: _selectedMotivo,
            items: ['Uso regular', 'Manutenção', 'Baixa de item'],
            onChanged: (value) => setState(() => _selectedMotivo = value),
          ),
          const SizedBox(height: 16),
          _buildFormTextFieldWithIcon(label: 'Data de saída', icon: Icons.calendar_today_outlined),
          const SizedBox(height: 16),
          _buildFormTextField(label: 'Responsável'),
          const SizedBox(height: 16),
          _buildFormTextField(label: 'Observações', maxLines: 3),
          const SizedBox(height: 24),
          _buildFormButtons(primaryText: 'Salvar Saída', onPrimaryPressed: () {}),
        ],
      ),
    );
  }


  /// Campo de texto simples
  Widget _buildFormTextField({required String label, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
      ],
    );
  }

  /// Campo de texto com ícone (para pesquisa ou data)
  Widget _buildFormTextFieldWithIcon({required String label, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            suffixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Campo de seleção falso (para "Quantidade" e "Base de destino" em Entrada)
  Widget _buildFormSelectionField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            // TODO: Abrir um modal ou outra tela para seleção
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '-', // Placeholder
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Campo de Dropdown (para "Destino" e "Motivo" em Saída)
  Widget _buildFormDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
      ],
    );
  }

  /// Botões de ação do formulário
  Widget _buildFormButtons({required String primaryText, required VoidCallback onPrimaryPressed}) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () {
            // TODO: Lógica de cancelar (ex: Navigator.pop(context) ou limpar campos)
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey[400]!),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: onPrimaryPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1763A6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(primaryText),
        ),
      ],
    );
  }
}