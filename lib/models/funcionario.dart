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
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      cargo: json['cargo'] as String,
    );
  }
}