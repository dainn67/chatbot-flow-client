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
  List<Conversation> get conversations =>
      _messages.map((msg) => Conversation(conversationId: msg.conversationId, appName: msg.appName)).toSet().toList();

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
    return _messages.where((msg) => msg.conversationId == conversationId).toList();
  }
}
