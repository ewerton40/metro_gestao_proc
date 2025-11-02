import 'package:flutter/material.dart';

// Importações para os widgets reutilizáveis
import 'package:metro_projeto/widgets/bar_menu.dart';
import 'package:metro_projeto/widgets/vertical_menu.dart';

// Um modelo simples para os dados da base
class BaseInfo {
  final String title;
  final String subtitle;
  final IconData icon;

  BaseInfo({required this.title, required this.subtitle, required this.icon});
}

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  // Lista de dados fictícios para os cartões
  final List<BaseInfo> _bases = [
    BaseInfo(
      title: 'WJA - Jabaquara',
      subtitle: 'Veículo de manuteção',
      icon: Icons.construction, // Ícone placeholder
    ),
    BaseInfo(
      title: 'PSO - Paraíso',
      subtitle: 'Veículo de manuteção',
      icon: Icons.construction,
    ),
    BaseInfo(
      title: 'TRD - Tiradentes',
      subtitle: 'Veículo de manuteção',
      icon: Icons.construction,
    ),
    BaseInfo(
      title: 'TUC - Tucuruvi',
      subtitle: 'Veículo de manuteção',
      icon: Icons.construction,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Cor de fundo geral
      appBar: const BarMenu(),
      drawer: const VerticalMenu(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildBaseGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  // Constrói o cabeçalho com o título e o botão
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Base',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Lógica para criar nova base
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Criar Base'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1763A6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // Constrói o grid (ou 'wrap') dos cartões
  Widget _buildBaseGrid(BuildContext context) {
    return Wrap(
      spacing: 24.0, // Espaço horizontal entre os cartões
      runSpacing: 24.0, // Espaço vertical entre as linhas de cartões
      children: _bases.map((base) => _buildBaseCard(base)).toList(),
    );
  }

  // Widget auxiliar para construir cada cartão de base
  Widget _buildBaseCard(BaseInfo base) {
    return Container(
      width: 300, // Largura fixa para cada cartão
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            base.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Icon(
            base.icon,
            size: 60,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 24),
          Text(
            base.subtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}