class Client {
  const Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String notes;
  final DateTime createdAt;

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
