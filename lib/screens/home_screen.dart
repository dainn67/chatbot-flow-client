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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessagesProvider>(context, listen: false).getMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFF8E1), Color(0xFFFFE8CC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border(bottom: BorderSide(color: Color(0xFFFFC107), width: 3)),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFC62828), Color(0xFFB71C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFC107), width: 2.5),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD32F2F).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                  BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 6)),
                ],
              ),
              child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ABC Chatbot Flow',
                  style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    shadows: [Shadow(color: Color(0xFFFFC107), blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Xuân Ất Tỵ 2026 🧧',
                  style: TextStyle(color: Color(0xFFD32F2F), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFFB300)]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Refresh',
              onPressed: () => context.read<MessagesProvider>().getMessages(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<MessagesProvider>(
        builder: (context, messagesProvider, child) => Row(
          children: [
            ConversationSidebar(messagesProvider: messagesProvider),
            Container(
              width: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFFC107), Color(0xFFD32F2F)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
            ),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFFFFDE7), Color(0xFFFFF8E1), Color(0xFFFFECB3)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFF8E1)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              border: const Border(bottom: BorderSide(color: Color(0xFFFFC107), width: 2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFC62828)]),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFC107), width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFFD32F2F).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: const Text('🏮', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB71C1C),
                          shadows: [Shadow(color: const Color(0xFFFFC107).withValues(alpha: 0.3), blurRadius: 4)],
                        ),
                      ),
                      Text(
                        'Chúc mừng năm mới',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFD32F2F)),
                      ),
                    ],
                  ),
                ),
              ],
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

                      return ConversationItem(appName: appName, flowTitle: flowTitle, isSelected: isSelected, onTap: () => messagesProvider.selectConversation(conversationId));
                    },
                  ),
          ),

          // Pagination
          _buildPagination(messagesProvider),
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
              gradient: const LinearGradient(colors: [Color(0xFFFFE082), Color(0xFFFFD54F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD32F2F), width: 2),
              boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Center(child: Text('🧧', style: TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có cuộc trò chuyện',
            style: TextStyle(fontSize: 14, color: const Color(0xFFD32F2F), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(MessagesProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFF8E1)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        border: const Border(top: BorderSide(color: Color(0xFFFFC107), width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          Container(
            decoration: BoxDecoration(
              gradient: provider.currentPage > 1 ? const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFC62828)]) : null,
              color: provider.currentPage > 1 ? null : const Color(0xFFFFE082),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: provider.currentPage > 1 ? const Color(0xFFFFC107) : const Color(0xFFFFD54F), width: 2),
              boxShadow: provider.currentPage > 1 ? [BoxShadow(color: const Color(0xFFD32F2F).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 20),
              onPressed: provider.currentPage > 1 ? () => provider.previousPage() : null,
              color: provider.currentPage > 1 ? Colors.white : const Color(0xFFD32F2F),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            ),
          ),
          const SizedBox(width: 16),

          // Page info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFFB300)]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD32F2F), width: 2),
              boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Text(
              'Page ${provider.currentPage}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                shadows: [Shadow(color: Color(0xFFD32F2F), blurRadius: 4)],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Next button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFC62828)]),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFC107), width: 2),
              boxShadow: [BoxShadow(color: const Color(0xFFD32F2F).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 20),
              onPressed: () => provider.nextPage(),
              color: Colors.white,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            ),
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

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://storage.googleapis.com/micro-enigma-235001.appspot.com/cms_v2/images/new_year_background.jpg'),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: selectedConversationId == null
              ? _buildEmptyState()
              : Builder(
                  builder: (context) {
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
                  },
                ),
        ),

        if (messagesProvider.loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network('https://storage.googleapis.com/micro-enigma-235001.appspot.com/cms_v2/images/new_year_loading.gif', fit: BoxFit.contain),
                  ),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFE082), Color(0xFFFFD54F), Color(0xFFFFC107)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(70),
              border: Border.all(color: const Color(0xFFD32F2F), width: 4),
              boxShadow: [
                BoxShadow(color: const Color(0xFFD32F2F).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 12)),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🏮', style: TextStyle(fontSize: 50)),
                  SizedBox(height: 4),
                  Text('✨', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFFB300)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD32F2F), width: 2),
            ),
            child: const Text(
              'Select a conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Color(0xFFD32F2F), blurRadius: 4)],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select a conversation from the list on the left',
            style: TextStyle(fontSize: 14, color: const Color(0xFFD32F2F), fontWeight: FontWeight.w600),
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
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFE082), Color(0xFFFFD54F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD32F2F), width: 3),
              boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Center(child: Text('🧧', style: TextStyle(fontSize: 50))),
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có tin nhắn',
            style: TextStyle(fontSize: 16, color: const Color(0xFFD32F2F), fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
