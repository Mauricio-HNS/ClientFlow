class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.senderName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderType;
  final String senderName;
  final String body;
  final DateTime createdAt;

  bool get isSalon => senderType.toLowerCase() == 'salon';

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderType: json['senderType'] as String? ?? 'salon',
      senderName: json['senderName'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
