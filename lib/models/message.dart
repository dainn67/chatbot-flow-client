class Message {
  final int id;
  final String message;
  final String role;
  final String appName;
  final String flowTitle;
  final String messageId;
  final String conversationId;
  final String createdAt;
  int seen;

  Message({
    required this.id,
    required this.messageId,
    required this.conversationId,
    required this.message,
    required this.createdAt,
    required this.role,
    required this.appName,
    required this.flowTitle,
    required this.seen,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      message: json['message'],
      role: json['role'],
      appName: json['app_name'],
      messageId: json['message_id'],
      conversationId: json['conversation_id'],
      createdAt: json['created_at'],
      flowTitle: json['flow_title'],
      seen: json['seen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'conversation_id': conversationId,
      'message': message,
      'created_at': createdAt,
      'role': role,
      'app_name': appName,
      'flow_title': flowTitle,
      'seen': seen,
    };
  }
}
