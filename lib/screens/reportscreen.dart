import 'package:flutter/material.dart';
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarMenu(),
      drawer: const VerticalMenu(),
      backgroundColor: const Color(0xFFF7F8F9),
      
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Relatórios',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Barra de pesquisa
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Pesquisar',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Filtros
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      label: Text('Categoria'),
                    ),
                    items: ['Todas'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      label: Text('Tipo'),
                    ),
                    items: ['Todas'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      label: Text('Período'),
                    ),
                    items: ['Últimos 30 dias'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      label: Text('Formato'),
                    ),
                    items: ['PDF'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            
            // Tabela de Relatórios
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Relatório', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Gerar', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: <DataRow>[
                    _buildDataRow('Movimentações', 'Entradas, saídas e transferências'),
                    _buildDataRow('Itens Críticos', 'Materiais com baixo estoque'),
                    _buildDataRow('Consumo', 'Materiais mais utilizados'),
                    _buildDataRow('Financeiro', 'Custos e valor de estoque'),
                    _buildDataRow('Pendências', 'Pedidos e aprovações aguardando'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String relatorio, String descricao) {
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(relatorio)),
        DataCell(Text(descricao)),
        DataCell(
          ElevatedButton(
            onPressed: () {},
            child: const Text('Gerar'),
          ),
        ),
      ],
    );
  }
}
