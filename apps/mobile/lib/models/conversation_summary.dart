class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String? lastMessage;
  final DateTime lastMessageAt;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String? ?? 'Cliente',
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
    );
  }
}
