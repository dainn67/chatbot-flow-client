import 'dart:convert';

import 'package:chatbotflowclient/models/message.dart';
import 'package:chatbotflowclient/screens/components/text_content_simple.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[_buildAvatar(false), const SizedBox(width: 12)],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: EdgeInsets.only(left: isUser ? 100 : 0, right: isUser ? 0 : 100),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser ? const Color(0xFF3B82F6).withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(message.message, isUser),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isUser ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[const SizedBox(width: 12), _buildAvatar(true)],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUser ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)] : [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: (isUser ? const Color(0xFF3B82F6) : const Color(0xFF8B5CF6)).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(isUser ? Icons.person_rounded : Icons.smart_toy_rounded, color: Colors.white, size: 20),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dateTimeUtc = DateTime.parse(timestamp).toUtc();
      final dateTimeLocal = dateTimeUtc.add(const Duration(hours: 7)); // +7 timezone
      final now = DateTime.now();
      final difference = now.difference(dateTimeLocal);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }

  Widget _buildMessageContent(String message, bool isUser) {
    final data = message.split('--//--');
    final isQuestion = message.startsWith('```json');

    final text = data.firstOrNull?.trim();
    final suggestedPrompts = data.length > 2 ? data.sublist(1, data.length - 1).map((e) => e.trim()).toList() : [];
    final summary = data.lastOrNull?.trim();

    final style = TextStyle(fontSize: 14, height: 1.5, color: isUser ? Colors.white : const Color(0xFF1A1A1A));

    // User message
    if (isUser) return Text(text ?? '', style: style);

    // Question message
    if (isQuestion) {
      final questionJson = jsonDecode(text?.replaceAll('```json', '').replaceAll('```', '') ?? '');
      final question = questionJson['question'];
      final options = questionJson['options'] as List<dynamic>;
      final explanation = questionJson['explanation'];
      final suggestedPrompts = questionJson['suggestedPrompts'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextContentSimple(inputText: question ?? '', style: style),
          const SizedBox(height: 12),
          ...options.mapIndexed(
            (index, option) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(6)),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(option['text'] ?? '', style: style)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFFD97706), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextContentSimple(inputText: explanation ?? '', style: style),
                ),
              ],
            ),
          ),
          if (suggestedPrompts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.grey.shade300, height: 1),
            ),
            Row(
              children: [
                ...suggestedPrompts.map(
                  (prompt) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                      ),
                      child: Center(
                        child: TextContentSimple(inputText: prompt, style: style),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextContentSimple(inputText: text ?? '', style: style),
        if (suggestedPrompts.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              ...suggestedPrompts.map(
                (prompt) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                    ),
                    child: Center(
                      child: TextContentSimple(inputText: prompt, style: style),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        if (summary != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.summarize_outlined, color: Color(0xFF15803D), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: TextContentSimple(inputText: summary, style: style),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
