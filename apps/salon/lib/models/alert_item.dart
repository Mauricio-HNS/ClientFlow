class AlertItem {
  AlertItem({
    required this.id,
    required this.title,
    required this.body,
    required this.tone,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String tone;
  final DateTime createdAt;

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      tone: json['tone'] as String? ?? 'info',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
