class NotificationModel {
  final int id;
  final String mensagem;
  final String data;
  final bool lida;

  NotificationModel({
    required this.id,
    required this.mensagem,
    required this.data,
    required this.lida,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final String dataUtc = json['data'] ?? '';
    final String dataLocal = dataUtc.isNotEmpty
        ? DateTime.parse(dataUtc + 'Z').toLocal().toString().substring(0, 16)
        : '';
        
    return NotificationModel(
      id: json['id'] as int,
      mensagem: json['mensagem'] as String,
      data: dataLocal, 
      lida: json['lida'] as bool,
    );
  }
}