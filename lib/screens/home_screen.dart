import 'package:chatbotflowclient/screens/components/conversation_item.dart';
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
        backgroundColor: Colors.grey.shade200,
        scrolledUnderElevation: 0,
        title: const Text(
          'Chatbotflow',
          style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 20, fontWeight: FontWeight.w600),
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
            // Sidebar - Danh sách cuộc hội thoại
            ConversationSidebar(messagesProvider: messagesProvider),

            // Divider
            Container(width: 1, color: const Color(0xFFE5E7EB)),

            // Khu vực chat chính
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
            padding: const EdgeInsets.all(20),
            child: Text(
              'Conversations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
            ),
          ),

          // List of conversations
          Expanded(
            child: messagesProvider.conversations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: messagesProvider.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = messagesProvider.conversations[index];
                      final conversationId = conversation.conversationId;
                      final appName = conversation.appName;
                      final isSelected = messagesProvider.selectedConversationId == conversationId;

                      return ConversationItem(
                        conversationId: conversationId,
                        appName: appName,
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
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No conversations', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
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
        final isUser = index % 2 == 0;

        return MessageBubble(message: message, isUser: isUser);
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
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(60)),
            child: const Icon(Icons.forum_outlined, size: 60, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select a conversation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
          ),
          const SizedBox(height: 8),
          Text('Select a conversation from the list on the left', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildNoMessagesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No messages', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
