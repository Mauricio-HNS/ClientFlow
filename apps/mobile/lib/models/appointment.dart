class Appointment {
  const Appointment({
    required this.id,
    required this.clientId,
    required this.title,
    required this.startAt,
    required this.durationMinutes,
    required this.notes,
    required this.status,
  });

  final String id;
  final String clientId;
  final String title;
  final DateTime startAt;
  final int durationMinutes;
  final String notes;
  final String status;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      title: json['title'] as String? ?? '',
      startAt: DateTime.parse(json['startAt'] as String),
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
      status: json['status'] as String? ?? 'pendente',
    );
  }
}
