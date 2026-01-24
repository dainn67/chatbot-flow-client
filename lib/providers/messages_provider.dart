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
  List<String>? _flowTitleFilter;
  String? get appNameFilter => _appNameFilter;
  List<String>? get flowTitleFilter => _flowTitleFilter;

  // Pagination
  int _currentPage = 1;
  int get currentPage => _currentPage;
  int itemsPerPage = 100;

  List<Conversation> get conversations {
    final seen = <String>{};
    final uniqueConversations = <Conversation>[];

    for (final msg in _messages) {
      if (!seen.contains(msg.conversationId)) {
        seen.add(msg.conversationId);
        uniqueConversations.add(Conversation(conversationId: msg.conversationId, appName: msg.appName, flowTitle: msg.flowTitle));
      }
    }
    return uniqueConversations;
  }

  String? _selectedConversationId;
  String? get selectedConversationId => _selectedConversationId;

  // Loading
  bool loading = false;

  // Set filters
  void setFilters(String? appName, List<String>? flowTitles) async {
    _appNameFilter = appName;
    _flowTitleFilter = flowTitles;
    _currentPage = 1;

    getMessages();
  }

  void nextPage() {
    _currentPage++;
    getMessages();
  }

  void previousPage() {
    _currentPage--;
    getMessages();
  }

  void selectConversation(String conversationId) {
    _selectedConversationId = conversationId;
    notifyListeners();
  }

  Future<void> getMessages() async {
    loading = true;
    notifyListeners();

    final queryParams = {
      if (_appNameFilter != null) 'app_name': _appNameFilter,
      if (_flowTitleFilter != null) 'flow_titles': _flowTitleFilter!.join(','),
      'skip': (_currentPage - 1) * itemsPerPage,
    };

    final response = await _apiService.get('/api/messages/get-messages', queryParams: queryParams);

    if (response.statusCode == 200) {
      try {
        final messageDataList = response.data as List<dynamic>;

        // No messages
        if (messageDataList.isEmpty) {
          debugPrint('No messages found');
          loading = false;
          notifyListeners();
          return;
        }

        // Clear and add messages
        _messages.clear();
        _messages.addAll(messageDataList.map((msg) => Message.fromJson(msg)));

        // Update state
        loading = false;
        selectConversation(_messages.first.conversationId);
        notifyListeners();
      } catch (e) {
        debugPrint('Error in getMessages: $e');
        loading = false;
        notifyListeners();
      }
    } else {
      debugPrint('Error getMessages status code: ${response.statusCode}: ${response.data}');
      loading = false;
      notifyListeners();
    }
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
