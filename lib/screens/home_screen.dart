import 'package:chatbotflowclient/screens/components/conversation_item.dart';
import 'package:chatbotflowclient/screens/components/filter_panel.dart';
import 'package:chatbotflowclient/screens/components/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/messages_provider.dart';

/// Màn hình chính của ứng dụng
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<MessagesProvider>(context, listen: false).getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFB)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Chatbotflow',
              style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B7280)),
            tooltip: 'Refresh',
            onPressed: () => context.read<MessagesProvider>().getMessages(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<MessagesProvider>(
        builder: (context, messagesProvider, child) => Row(
          children: [
            ConversationSidebar(messagesProvider: messagesProvider),
            Container(width: 1, color: const Color(0xFFE5E7EB)),
            Expanded(child: ChatArea(messagesProvider: messagesProvider)),
          ],
        ),
      ),
    );
  }
}

/// Widget sidebar hiển thị danh sách cuộc hội thoại
class ConversationSidebar extends StatelessWidget {
  final MessagesProvider messagesProvider;

  const ConversationSidebar({super.key, required this.messagesProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Conversations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
            ),
          ),

          // Filter Panel
          FilterPanel(
            appNameFilter: messagesProvider.appNameFilter,
            flowTitleFilter: messagesProvider.flowTitleFilter,
            onFilterChanged: (appName, flowTitles) {
              messagesProvider.setFilters(appName, flowTitles);
            },
          ),

          // List of conversations
          Expanded(
            child: messagesProvider.conversations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: messagesProvider.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = messagesProvider.conversations[index];
                      final conversationId = conversation.conversationId;
                      final appName = conversation.appName;
                      final flowTitle = conversation.flowTitle;
                      final isSelected = messagesProvider.selectedConversationId == conversationId;

                      return ConversationItem(
                        appName: appName,
                        flowTitle: flowTitle,
                        isSelected: isSelected,
                        onTap: () => messagesProvider.selectConversation(conversationId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.grey.shade100, Colors.grey.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Widget khu vực chat chính
class ChatArea extends StatelessWidget {
  final MessagesProvider messagesProvider;

  const ChatArea({super.key, required this.messagesProvider});

  @override
  Widget build(BuildContext context) {
    final selectedConversationId = messagesProvider.selectedConversationId;

    if (selectedConversationId == null) {
      return _buildEmptyState();
    }

    final messages = messagesProvider.getMessagesByConversationId(selectedConversationId);

    if (messages.isEmpty) {
      return _buildNoMessagesState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      reverse: false,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(message: message);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: const Icon(Icons.forum_outlined, size: 60, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select a conversation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF374151), letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a conversation from the list on the left',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMessagesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.grey.shade100, Colors.grey.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
