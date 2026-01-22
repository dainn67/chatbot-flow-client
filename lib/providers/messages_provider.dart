import 'package:chatbotflowclient/models/conversation.dart';
import 'package:chatbotflowclient/models/message.dart';
import 'package:chatbotflowclient/services/api_service.dart';
import 'package:flutter/foundation.dart';

class MessagesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Messages
  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  // Conversation IDs
  List<Conversation> get conversations {
    final seen = <String>{};
    final uniqueConversations = <Conversation>[];
    for (final msg in _messages) {
      if (!seen.contains(msg.conversationId)) {
        seen.add(msg.conversationId);
        uniqueConversations.add(Conversation(conversationId: msg.conversationId, appName: msg.appName));
      }
    }
    return uniqueConversations;
  }

  String? _selectedConversationId;
  String? get selectedConversationId => _selectedConversationId;

  void selectConversation(String conversationId) {
    _selectedConversationId = conversationId;
    notifyListeners();
  }

  Future<void> getMessages() async {
    final response = await _apiService.get('/api/messages/get-all');
    final messageDataList = response.data as List<dynamic>;
    _messages.clear();
    _messages.addAll(messageDataList.map((msg) => Message.fromJson(msg)));
    notifyListeners();
  }

  List<Message> getMessagesByConversationId(String conversationId) {
    final messages = _messages.where((msg) => msg.conversationId == conversationId).toList();

    messages.sort((a, b) {
      final dateA = DateTime.tryParse(a.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = DateTime.tryParse(b.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);

      if (dateA.compareTo(dateB) != 0) {
        return dateA.compareTo(dateB);
      } else {
        if (a.role == 'user' && b.role != 'user') return -1;
        if (a.role != 'user' && b.role == 'user') return 1;
        return 0;
      }
    });

    return messages;
  }
}
