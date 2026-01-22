import 'package:chatbotflowclient/models/conversation.dart';
import 'package:chatbotflowclient/models/message.dart';
import 'package:chatbotflowclient/services/api_service.dart';
import 'package:flutter/foundation.dart';

class MessagesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Messages
  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  // Filters
  String? _appNameFilter;
  String? _flowTitleFilter;
  String? get appNameFilter => _appNameFilter;
  String? get flowTitleFilter => _flowTitleFilter;

  // Conversation IDs
  List<Conversation> get conversations {
    final seen = <String>{};
    final uniqueConversations = <Conversation>[];

    // Lọc messages trước khi tạo conversations
    final filteredMessages = _getFilteredMessages();

    for (final msg in filteredMessages) {
      if (!seen.contains(msg.conversationId)) {
        seen.add(msg.conversationId);
        uniqueConversations.add(Conversation(conversationId: msg.conversationId, appName: msg.appName));
      }
    }
    return uniqueConversations;
  }

  String? _selectedConversationId;
  String? get selectedConversationId => _selectedConversationId;

  // Lọc messages dựa trên filter
  List<Message> _getFilteredMessages() {
    if (_appNameFilter == null && _flowTitleFilter == null) {
      return _messages;
    }

    return _messages.where((msg) {
      bool matchAppName = true;
      bool matchFlowTitle = true;

      if (_appNameFilter != null && _appNameFilter!.isNotEmpty) {
        matchAppName = msg.appName.toLowerCase().contains(_appNameFilter!.toLowerCase());
      }

      if (_flowTitleFilter != null && _flowTitleFilter!.isNotEmpty) {
        matchFlowTitle = msg.flowTitle.toLowerCase().contains(_flowTitleFilter!.toLowerCase());
      }

      return matchAppName && matchFlowTitle;
    }).toList();
  }

  // Set filters
  void setFilters(String? appName, String? flowTitle) {
    _appNameFilter = appName;
    _flowTitleFilter = flowTitle;

    // Reset selected conversation nếu nó không còn trong danh sách filter
    if (_selectedConversationId != null) {
      final conversationIds = conversations.map((c) => c.conversationId).toList();
      if (!conversationIds.contains(_selectedConversationId)) {
        _selectedConversationId = null;
      }
    }

    notifyListeners();
  }

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
    final filteredMessages = _getFilteredMessages();
    final messages = filteredMessages.where((msg) => msg.conversationId == conversationId).toList();

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
