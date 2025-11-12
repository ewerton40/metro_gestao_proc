class SimpleLocation {
  final int id;
  final String nome;

  SimpleLocation({required this.id, required this.nome});

  factory SimpleLocation.fromJson(Map<String, dynamic> json) {
    return SimpleLocation(
      id: int.parse(json['id'].toString()),
      nome: json['nome'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SimpleLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}