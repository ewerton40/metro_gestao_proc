// --- NOVO: Imports para fazer a requisição HTTP e decodificar o JSON ---
import 'dart:convert';
import 'package:http/http.dart' as http;
// --- FIM NOVO ---

import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';

// Um modelo de dados simples para representar um item do inventário.
class InventoryItem {
  final String code;
  final String name;
  final String category;
  final String status;
  final String base;
  final String lastMoved;

  InventoryItem({
    required this.code,
    required this.name,
    required this.category,
    required this.status,
    required this.base,
    required this.lastMoved,
  });

  // --- NOVO: Construtor 'factory' para criar um item a partir do JSON ---
  // Este método converte o Map (JSON) que vem da API em um objeto InventoryItem
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      // Usamos '?? '' ' para garantir que, se um valor vier nulo do banco,
      // ele se torne uma string vazia no app, evitando erros.
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? '',
      base: json['base'] ?? '',
      lastMoved: json['lastMoved'] ?? '',
    );
  }
  // --- FIM NOVO ---
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // --- Variáveis de Estado para os Filtros ---
  String? _selectedStatus;
  String? _selectedCategory;
  String? _selectedBase;
  String? _selectedMovement;
  String _searchText = '';
  
  // --- Listas de Opções para os Dropdowns ---
  final List<String> _statusOptions = ['Todos', 'Em estoque', 'Baixo estoque', 'Esgotado'];
  final List<String> _categoryOptions = ['Todas', 'Spare Parts', 'Ferramentas', 'Equipamento'];
  final List<String> _baseOptions = ['Todas', 'Base Central', 'Base Sul', 'Base Leste', 'Base Oeste'];
  final List<String> _movementOptions = ['Qualquer data', 'Últimos 7 dias', 'Últimos 30 dias'];


  // --- MODIFICADO: Lista de Dados ---
  // A lista agora começa vazia e será preenchida pela API.
  List<InventoryItem> _items = [];
  
  // --- NOVO: Variáveis de estado para controlar o carregamento ---
  bool _isLoading = true; // Começa como 'true' para mostrar o "carregando"
  String _errorMessage = ''; // Para guardar mensagens de erro
  // --- FIM NOVO ---
  

  // --- NOVO: Método 'initState' ---
  // Este método é chamado automaticamente 1 vez quando a tela é criada.
  // É o lugar perfeito para buscar os dados iniciais.
  @override
  void initState() {
    super.initState();
    _fetchInventoryItems(); // Chama a função que busca os dados
  }
  // --- FIM NOVO ---

  // --- NOVO: Função para buscar os dados da sua API ---
  Future<void> _fetchInventoryItems() async {
    // A URL do seu endpoint no Dart Frog
    // IMPORTANTE: Veja a nota sobre 'localhost' no final da resposta!
    final url = Uri.parse('http://localhost:8080/inventory');

    try {
      // Faz a requisição GET
      final response = await http.get(url);

      // Verifica se a requisição foi um sucesso (código 200)
      if (response.statusCode == 200) {
        // Decodifica o JSON (que é uma lista de mapas)
        final List<dynamic> data = jsonDecode(response.body);

        // Atualiza o estado do widget (isso redesenha a tela)
        setState(() {
          // Converte cada item do JSON em um objeto InventoryItem
          _items = data.map((json) => InventoryItem.fromJson(json)).toList();
          _isLoading = false; // Para de carregar
        });
      } else {
        // Se o servidor respondeu com um erro (404, 500, etc)
        setState(() {
          _errorMessage = 'Falha ao carregar dados do servidor.';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Se ocorreu um erro de rede (sem internet, servidor desligado, etc)
      print('Erro de rede: $e');
      setState(() {
        _errorMessage = 'Erro de conexão. Verifique sua rede ou o servidor.';
        _isLoading = false;
      });
    }
  }
  // --- FIM NOVO ---


  @override
  Widget build(BuildContext context) {
    // --- MODIFICADO: A lógica de filtro continua IGUAL ---
    // Ela agora vai operar sobre a lista '_items' que foi preenchida pela API.
    List<InventoryItem> filteredItems = _items;

    // ... (toda a sua lógica de 'filteredItems' continua aqui) ...
    // Filtros de Dropdown
    if (_selectedStatus != null && _selectedStatus != 'Todos') { // Ajuste para 'Todos'
      filteredItems = filteredItems.where((item) => item.status == _selectedStatus).toList();
    }
    if (_selectedCategory != null && _selectedCategory != 'Todas') { // Ajuste para 'Todas'
      filteredItems = filteredItems.where((item) => item.category == _selectedCategory).toList();
    }
    if (_selectedBase != null && _selectedBase != 'Todas') { // Ajuste para 'Todas'
      filteredItems = filteredItems.where((item) => item.base == _selectedBase).toList();
    }
    // ... (o resto da lógica de filtro) ...

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: const BarMenu(),
      drawer: const VerticalMenu(),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchAndFilters(),
            const SizedBox(height: 24),
            
            // --- MODIFICADO: Lógica para exibir "Carregando" ou "Erro" ---
            Expanded(
              child: _isLoading
                  // 1. Se estiver carregando, mostra o 'CircularProgressIndicator'
                  ? const Center(child: CircularProgressIndicator())
                  // 2. Se deu erro, mostra a mensagem
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)))
                      // 3. Se tudo deu certo, mostra a tabela
                      : _buildDataTable(filteredItems),
            ),
            // --- FIM MODIFICADO ---

            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ... O RESTO DO SEU CÓDIGO (_buildHeader, _buildSearchAndFilters, 
  // _buildDataTable, _getStatusWidget, _buildFooter)
  // continua EXATAMENTE IGUAL ...
  
  // (Cole o resto do seu código original aqui)

  // Constrói o cabeçalho da área de conteúdo.
  Widget _buildHeader() {
    return const Row(
      children: [
        Text(
          'Inventário',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Constrói a barra de pesquisa e os filtros.
  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Pesquisar item...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Dropdown Categoria
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedCategory,
                hint: 'Todas',
                items: _categoryOptions,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = (newValue == 'Todas') ? null : newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            
            // Dropdown Status
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedStatus,
                hint: 'Todos',
                items: _statusOptions,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = (newValue == 'Todos') ? null : newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),

            // Dropdown Base Operacional
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedBase,
                hint: 'Todas',
                items: _baseOptions,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBase = (newValue == 'Todas') ? null : newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),

            // Dropdown Última Movimentação
            Expanded(
              child: _buildFilterDropdown(
                value: _selectedMovement,
                hint: 'Qualquer data',
                items: _movementOptions,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMovement = (newValue == 'Qualquer data') ? null : newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget auxiliar para criar os dropdowns de filtro
  Widget _buildFilterDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      // MODIFICADO: Para garantir que o hint 'Todas' apareça
      value: value ?? hint, 
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }
  
  // Constrói a tabela de dados.
  Widget _buildDataTable(List<InventoryItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
          columns: const [
            DataColumn(label: Text('Código / Nome do Item')),
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Base Operacional')),
            DataColumn(label: Text('Última Movimentação')),
          ],
          rows: items.map((item) {
            return DataRow(cells: [
              DataCell(Text(item.code.isNotEmpty ? item.code : item.name)),
              DataCell(Text(item.category)),
              DataCell(_getStatusWidget(item.status)),
              DataCell(Text(item.base)),
              DataCell(Text(item.lastMoved)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // Retorna um widget estilizado para o status do item.
  Widget _getStatusWidget(String status) {
    // ... (Sem alterações neste método)
    Color color;
    switch (status) {
      case 'Em estoque':
        color = Colors.green;
        break;
      case 'Baixo estoque':
        color = Colors.orange;
        break;
      case 'Esgotado':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold));
  }

  // Constrói o rodapé com os botões e informações.
  Widget _buildFooter() {
    // ... (Sem alterações neste método)
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1763A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Visualizar Item'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1763A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cadastrar Itens'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total de itens cadastrados: 160', style: TextStyle(color: Colors.grey)),
            Text('Total de itens críticos: 20', style: TextStyle(color: Colors.grey)),
            Text('Última atualização, 02/01/2024', style: TextStyle(color: Colors.grey)),
          ],
        )
      ],
    );
  }
}