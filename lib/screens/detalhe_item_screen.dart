import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';
import 'package:metro_projeto/services/inventory_service.dart';
import '../services/movimentation_services.dart';

class DetalheItemScreen extends StatefulWidget {
  const DetalheItemScreen({super.key});

  @override
  State<DetalheItemScreen> createState() => _DetalheItemScreenState();
}

class _DetalheItemScreenState extends State<DetalheItemScreen> {
  final bool disponivel = true;
  Map<String, dynamic>? _itemDetalhe;
  bool _isLoadingDetalhe = false;

  final InventoryServices _inventario = InventoryServices();
  final MovimentationServices _movimentacao = MovimentationServices();
  List<String> _opcoesMateriais = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final List<Map<String, dynamic>> _movimentacoesTeste = [
  {'data': '05/11/2025', 'tipo': 'Entrada', 'quantidade': 10, 'responsavel': 'Ana C.'},
  {'data': '04/11/2025', 'tipo': 'Saída', 'quantidade': 3, 'responsavel': 'Pedro L.'},
  {'data': '03/11/2025', 'tipo': 'Entrada', 'quantidade': 25, 'responsavel': 'João S.'},
  {'data': '02/11/2025', 'tipo': 'Saída', 'quantidade': 7, 'responsavel': 'Maria A.'},
  {'data': '01/11/2025', 'tipo': 'Saída', 'quantidade': 2, 'responsavel': 'Carlos D.'},
  {'data': '31/10/2025', 'tipo': 'Entrada', 'quantidade': 5, 'responsavel': 'Rita F.'},
  {'data': '30/10/2025', 'tipo': 'Saída', 'quantidade': 1, 'responsavel': 'Bruno G.'},
  {'data': '29/10/2025', 'tipo': 'Saída', 'quantidade': 4, 'responsavel': 'Telmo H.'},
];

  @override
  void initState() {
    super.initState();
    _fetchMateriais();
  }

  Future<void> _fetchMateriais() async {
    try {
      final items = await _inventario.getAllItems();
      setState(() {
        _opcoesMateriais =
            items.map((e) => e.nome).where((n) => n.isNotEmpty).toList();
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar materiais.';
        _opcoesMateriais.clear();
        _isLoading = false;
      });
    }
  }

  Widget _buildHistoricoTable(List<dynamic> movimentacoes) {

    final headerRow = const TableRow(
      decoration: BoxDecoration(color: Color.fromARGB(168, 95, 165, 251)), // Cabeçalho com fundo
      children: [
        Padding(
          padding: EdgeInsets.all(10.0), // Aumentei o padding  
          child: Text("Data", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("Tipo", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child:
              Text("Quantidade", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child:
              Text("Responsável", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );


    final dataRows = movimentacoes.map((mov) {
      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(mov['data']?.toString() ?? 'N/A'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(mov['tipo']?.toString() ?? 'N/A'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(mov['quantidade']?.toString() ?? 'N/A'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(mov['responsavel']?.toString() ?? 'N/A'),
          ),
        ],
      );
    }).toList();

    return Table(
      border: TableBorder.symmetric(
        inside: const BorderSide(color: Colors.black12),
        outside: const BorderSide(color: Colors.grey), 
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        headerRow,
        ...dataRows, // Linhas de dados dinâmicas
      ],
    );
  }

 
  Future<void> _mostrarHistoricoCompleto(
      BuildContext context, List<dynamic> historico) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Histórico Completo de Movimentações"),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.6, 
            height: MediaQuery.of(context).size.height * 0.7, 
            child: SingleChildScrollView(
              // Permite rolar se o histórico for muito grande
              child: _buildHistoricoTable(historico), 
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FB),
      appBar: const BarMenu(),
      drawer: const VerticalMenu(),
      body: Column(
        children: [
          // WIDGET DE PESQUISA
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }

                return _opcoesMateriais.where((String option) {
                  return option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) async {
                setState(() {
                  _isLoadingDetalhe = true;
                  _itemDetalhe = null;
                });

                try {
                  final allItems = await _inventario.getAllItems();
                  final item =
                      allItems.firstWhere((e) => e.nome == selection);

                  final detalhe = await _inventario.getItemDetail(item.id);
                  final historico = await _movimentacao.getItemHistory(item.id);

                  detalhe['movimentacoes'] = historico['movimentacoes'] ?? [];
                  setState(() {
                    _itemDetalhe = detalhe;
                    _isLoadingDetalhe = false;
                  });
                } catch (e) {
                  setState(() {
                    _itemDetalhe = null;
                    _isLoadingDetalhe = false;
                    _errorMessage = 'Erro ao carregar detalhes: $e';
                  });
                }
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    hintText: _isLoading
                        ? 'Carregando materiais...'
                        : 'Pesquisar material...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options) {
                if (_errorMessage.isNotEmpty) {
                  return const SizedBox.shrink();
                }

                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(8.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return InkWell(
                            onTap: () {
                              onSelected(option);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Visibility(
            visible: _isLoading,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
              child: LinearProgressIndicator(
                color: Color(0xFF001789),
              ),
            ),
          ),
          Visibility(
            visible: _errorMessage.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            ),
          ),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Detalhe do Item",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (_isLoadingDetalhe)
                          const Center(child: CircularProgressIndicator())
                        else if (_itemDetalhe == null)
                          const Text("Selecione um item para ver os detalhes.",
                              style: TextStyle(color: Colors.red))
                        else
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 35,
                                          backgroundColor: Colors.grey,
                                          child: Icon(Icons.inventory_2,
                                              color: Colors.white, size: 40),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _itemDetalhe!['nome_material'] ??
                                                    '',
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                  "Código: ${_itemDetalhe!['codigo']}"),
                                              Text(
                                                  "Categoria: ${_itemDetalhe!['categoria']}"),
                                              Text(
                                                  "Descrição: ${_itemDetalhe!['descricao']}"),
                                              Text(
                                                  "Estoque mínimo: ${_itemDetalhe!['estoque_minimo']}"),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Quantidade: ${_itemDetalhe!['quantidade']}",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  const Text("Status: "),
                                                  Text(
                                                    _itemDetalhe!['status'] ??
                                                        '',
                                                    style: TextStyle(
                                                      color: _itemDetalhe![
                                                                  'status'] ==
                                                              'Crítico'
                                                          ? Colors.red
                                                          : Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                  "Localização: ${_itemDetalhe!['localizacao']}"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  const Text(
                                    "Histórico de Movimentações",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                         
                                  Builder(builder: (context) {
                                    final List<dynamic> todasMovimentacoes =
                                        _itemDetalhe!['movimentacoes'] ?? [];

                                    if (todasMovimentacoes.isEmpty) {
                                      return const Text(
                                          "Nenhuma movimentação registrada.");
                                    }

                                    final List<dynamic> ultimasCinco =
                                        todasMovimentacoes
                                            .take(5)
                                            .toList();

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildHistoricoTable(ultimasCinco),

                                        const SizedBox(height: 10),

                                        if (todasMovimentacoes.length > 5)
                                          Align(
                                           child: ElevatedButton(
                                              onPressed: () {
                                                _mostrarHistoricoCompleto(
                                                    context,
                                                    todasMovimentacoes);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF001789), 
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                              ),
                                              child: const Text(
                                                  "Ver Histórico Completo",
                                                  style: TextStyle(
                                                      color: Colors.white, 
                                                      fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}