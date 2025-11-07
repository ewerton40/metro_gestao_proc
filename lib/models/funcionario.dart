class Funcionario {
  final int id;
  final String nome;
  final String email;
  final String cargo;

  Funcionario({
    required this.id,
    required this.nome,
    required this.email,
    required this.cargo,
  });

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    return Funcionario(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      cargo: json['cargo'] ?? '',
    );
  }
}
