class SalonStatusLog {
  SalonStatusLog({
    required this.id,
    required this.fromStatus,
    required this.toStatus,
    required this.createdAt,
  });

  final String id;
  final String fromStatus;
  final String toStatus;
  final DateTime createdAt;

  factory SalonStatusLog.fromJson(Map<String, dynamic> json) {
    return SalonStatusLog(
      id: json['id'] as String,
      fromStatus: json['fromStatus'] as String? ?? 'ACTIVE',
      toStatus: json['toStatus'] as String? ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
