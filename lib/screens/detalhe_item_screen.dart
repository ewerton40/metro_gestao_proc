import 'package:flutter/material.dart';

class DetalheItemScreen extends StatelessWidget {
  const DetalheItemScreen({super.key});
  final bool disponivel = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FB),
      body: Row(
        children: [
          // Menu lateral
          Container(
            width: 220,
            color: const Color(0xFFE3F2FD),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + título
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.image, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Metro de São\nPaulo",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text("Dashboard"),
                ),
                const ListTile(
                  leading: Icon(Icons.inventory_2),
                  title: Text("Inventário"),
                ),
                const ListTile(
                  leading: Icon(Icons.login),
                  title: Text("Entradas"),
                ),
              ],
            ),
          ),

          // Conteúdo principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
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

                  // Card principal
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
                          child: Icon(Icons.lightbulb, color: Colors.white, size: 40),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Lanterna LED",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text("Código: L-100"),
                              const Text("Categoria: Equipamentos"),
                              const Text("Descrição: Lanterna de mão com LED"),
                              const Text("Estoque mínimo: 5"),
                              const SizedBox(height: 8),
                              const Text(
                                "Quantidade: 28",
                                style: TextStyle(
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
                                    disponivel ? "Disponível" : "Indisponível",
                                    style: TextStyle(
                                      color: disponivel ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Text("Localização: Base A"),
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

                  // Tabela de histórico
                  Table(
                    border: TableBorder.symmetric(
                      inside: const BorderSide(color: Colors.black12),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                    },
                    children: const [
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Data", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Tipo", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Quantidade", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Responsável", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      TableRow(children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text("20/04/2024")),
                        Padding(padding: EdgeInsets.all(8.0), child: Text("Entrada")),
                        Padding(padding: EdgeInsets.all(8.0), child: Text("15")),
                        Padding(padding: EdgeInsets.all(8.0), child: Text("João")),
                      ]),
                      TableRow(children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text("15/04/2024")),
                        Padding(padding: EdgeInsets.all(8.0), child: Text("Saída")),
                        Padding(padding: EdgeInsets.all(8.0), child: Text("7")),
                        Padding(padding: EdgeInsets.all(8.0), child: Text("Maria")),
                      ]),
                      TableRow(children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text("10/04/2024")),
                        Padding(padding: EdgeInsets.all(8.0), child: Text("Saída")),
                        Padding(padding: EdgeInsets.all(8.0), child: Text("3")),
                        Padding(padding: EdgeInsets.all(8.0), child: Text("Anselmo")),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
