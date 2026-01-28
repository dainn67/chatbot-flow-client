import 'package:chatbotflowclient/configs/api_config.dart';
import 'package:chatbotflowclient/models/conversation.dart';
import 'package:chatbotflowclient/models/message.dart';
import 'package:chatbotflowclient/services/api_service.dart';
import 'package:flutter/foundation.dart';

class MessagesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // All messages from server (full dataset)
  final List<Message> _allMessages = [];

  // Filtered and paginated messages for display
  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  // Filters
  String? _appNameFilter;
  List<String>? _flowTitleFilter;
  String? get appNameFilter => _appNameFilter;
  List<String>? get flowTitleFilter => _flowTitleFilter;

  // Pagination
  final int itemsPerPage = 100;
  final int limitPerRequest = 500;
  int _currentPage = 1;
  int get currentPage => _currentPage;

  List<Conversation> get conversations {
    final seenConversations = <String>{};
    final uniqueConversations = <Conversation>[];

    for (final msg in _messages) {
      if (!seenConversations.contains(msg.conversationId)) {
        seenConversations.add(msg.conversationId);

        // Check if any message in this conversation has seen == 1
        bool anySeen = _messages.any((m) => m.conversationId == msg.conversationId && m.seen == 1);

        uniqueConversations.add(Conversation(conversationId: msg.conversationId, appName: msg.appName, flowTitle: msg.flowTitle, seen: anySeen));
      }
    }
    return uniqueConversations;
  }

  String? _selectedConversationId;
  String? get selectedConversationId => _selectedConversationId;

  // Loading
  bool loading = false;

  // Set filters
  void setFilters(String? appName, List<String>? flowTitles) {
    _appNameFilter = appName;
    _flowTitleFilter = flowTitles;
    _currentPage = 1;

    _applyFiltersAndPagination();
  }

  void nextPage() {
    _currentPage++;
    _applyFiltersAndPagination();
  }

  void previousPage() {
    _currentPage--;
    _applyFiltersAndPagination();
  }

  // Apply filters and pagination to local messages
  void _applyFiltersAndPagination() {
    // Start with all messages
    List<Message> filtered = List.from(_allMessages);

    // Apply app name filter
    if (_appNameFilter != null && _appNameFilter!.isNotEmpty) {
      filtered = filtered.where((msg) => msg.appName == _appNameFilter).toList();
    }

    // Apply flow title filter
    if (_flowTitleFilter != null && _flowTitleFilter!.isNotEmpty) {
      filtered = filtered.where((msg) => _flowTitleFilter!.contains(msg.flowTitle)).toList();
    }

    // Apply pagination
    final startIndex = (_currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    _messages.clear();
    if (startIndex < filtered.length) {
      _messages.addAll(filtered.sublist(startIndex, endIndex > filtered.length ? filtered.length : endIndex));
    }

    notifyListeners();
  }

  void selectConversation(String conversationId) {
    if (_selectedConversationId != conversationId) {
      _selectedConversationId = conversationId;
      notifyListeners();

      final messages = getMessagesByConversationId(conversationId);
      if (messages.any((msg) => msg.seen == 1)) return;

      // Update local seen status
      messages.firstOrNull?.seen = 1;
      notifyListeners();

      // Update server seen status
      _apiService.post(ApiConfig.markAsSeenEndpoint, body: {'conversation_id': conversationId}).then((result) {
        if (result.statusCode != 200) debugPrint('Error mark as seen: ${result.statusCode}: ${result.data}');
      });
    }
  }

  // Main functions
  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _apiService.get(ApiConfig.healthEndpoint);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      return {'status': 'failed', 'message': 'Health check failed: ${response.statusCode}: ${response.data}'};
    }
  }

  // Load all messages from server (call only initially or on reload)
  Future<void> getMessages() async {
    if (loading) return;

    loading = true;
    notifyListeners();

    final queryParams = {
      if (_appNameFilter != null) 'app_name': _appNameFilter,
      if (_flowTitleFilter != null) 'flow_titles': _flowTitleFilter!.join(','),
      'skip': (_currentPage - 1) * itemsPerPage,
      'limit': limitPerRequest,
    };

    final response = await _apiService.get(ApiConfig.getMessagesEndpoint, queryParams: queryParams);

    if (response.statusCode == 200) {
      try {
        final messageDataList = response.data as List<dynamic>;

        _selectedConversationId = null;

        // Clear all messages
        _allMessages.clear();
        _messages.clear();

        // No messages
        if (messageDataList.isEmpty) {
          debugPrint('No messages found');
          loading = false;
          notifyListeners();
          return;
        }

        // Store all messages to local list
        _allMessages.addAll(messageDataList.map((msg) => Message.fromJson(msg)));

        // Apply filters and pagination to display
        _applyFiltersAndPagination();

        // Update state
        loading = false;
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
    // Get messages from all messages, not just current page
    final messages = _allMessages.where((msg) => msg.conversationId == conversationId).toList();

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

  Future<bool> deleteAllMessages() async {
    _messages.clear();
    _currentPage = 1;
    _selectedConversationId = null;
    _appNameFilter = null;
    _flowTitleFilter = null;

    final result = await _apiService.post('/api/messages/clear-all-messages');
    if (result.statusCode != 200) return false;
    notifyListeners();

    return result.success;
  }
}
