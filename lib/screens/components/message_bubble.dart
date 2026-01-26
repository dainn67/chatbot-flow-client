import 'dart:convert';

import 'package:chatbotflowclient/configs/api_config.dart';
import 'package:chatbotflowclient/models/message.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[_buildAvatar(false), const SizedBox(width: 14)],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              margin: EdgeInsets.only(left: isUser ? 100 : 0, right: isUser ? 0 : 100),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFC62828), Color(0xFFB71C1C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFF8E1)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                border: Border.all(color: isUser ? const Color(0xFFFFC107) : const Color(0xFFFFE082), width: 2.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 20 : 6),
                  topRight: Radius.circular(isUser ? 6 : 20),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser ? const Color(0xFFD32F2F).withValues(alpha: 0.3) : const Color(0xFFFFC107).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                  if (isUser) BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(message.message, isUser),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🎋', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isUser ? Colors.white.withValues(alpha: 0.9) : const Color(0xFFD32F2F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[const SizedBox(width: 14), _buildAvatar(true)],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUser
              ? [const Color(0xFFD32F2F), const Color(0xFFC62828), const Color(0xFFB71C1C)]
              : [const Color(0xFFFFC107), const Color(0xFFFFB300), const Color(0xFFFFA000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUser ? const Color(0xFFFFC107) : const Color(0xFFD32F2F), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: (isUser ? const Color(0xFFD32F2F) : const Color(0xFFFFC107)).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: (isUser ? const Color(0xFFFFC107) : const Color(0xFFD32F2F)).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(isUser ? Icons.person_rounded : Icons.smart_toy_rounded, color: Colors.white, size: 22),
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFFFC107) : const Color(0xFFD32F2F),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? const Color(0xFFFFC107) : const Color(0xFFD32F2F)).withValues(alpha: 0.6),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

    final style = TextStyle(fontSize: 14, height: 1.5, color: isUser ? Colors.white : const Color(0xFF5D4037), fontWeight: FontWeight.w500);

    // User message
    if (isUser) return SelectableText(text ?? '', style: style);

    // Question message
    if (isQuestion) {
      try {
        final questionDataJson = jsonDecode(text?.replaceAll('```json', '').replaceAll('```', '') ?? '');
        return ApiConfig.isABC ? _buildSingleQuestion(questionDataJson, style) : _buildMultipleQuestions(questionDataJson, style);
      } catch (e) {
        return SelectableText(text ?? '', style: style);
      }
    }

    // Bot response message
    return _buildDefaultBotResponse(text, suggestedPrompts, summary, style);
  }

  Widget _buildSingleQuestion(Map<String, dynamic> questionJson, TextStyle style) {
    final question = questionJson['question'] ?? '';
    final options = questionJson['options'] as List<dynamic>;
    final explanation = questionJson['explanation'] ?? '';
    final suggestedPrompts = questionJson['suggestedPrompts'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(question, style: style),
        const SizedBox(height: 12),
        ...options.mapIndexed(
          (index, option) => Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFF8E1), Color(0xFFFFE8CC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD32F2F), width: 2),
              boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFC62828)]),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFC107), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: SelectableText(option['text'] ?? '', style: style)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFF59D), Color(0xFFFFEE58)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD32F2F), width: 2),
            boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Text('💡', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SelectableText(explanation, style: style.copyWith(color: const Color(0xFF5D4037))),
              ),
            ],
          ),
        ),
        if (suggestedPrompts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey.shade300, height: 1),
          ),
          _buildSuggestedPrompts(suggestedPrompts, style),
        ],
      ],
    );
  }

  Widget _buildMultipleQuestions(Map<String, dynamic> questionJson, TextStyle style) {
    final questionsJson = questionJson['questions'] as List<dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: questionsJson.mapIndexed((qIndex, question) {
        final questionText = question['question'];
        final options = question['answers'] as List<dynamic>;
        final explanation = question['explanation'];
        final audio = question['audio'];
        final type = question['type'];

        return Container(
          margin: EdgeInsets.only(bottom: qIndex < questionsJson.length - 1 ? 20 : 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFFBF0), Color(0xFFFFF8E1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD32F2F), width: 2.5),
            boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question header with number
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFC62828)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFC107), width: 2.5),
                      boxShadow: [BoxShadow(color: const Color(0xFFD32F2F).withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Center(
                      child: Text(
                        '${qIndex + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SelectableText(
                      questionText ?? '',
                      style: style.copyWith(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF5D4037)),
                    ),
                  ),

                  // Question type badge
                  if (type != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFC107), Color(0xFFFFB300)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD32F2F), width: 2),
                        boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Text(
                            type,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Audio indicator
              if (audio != null && audio.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE8CC), Color(0xFFFFD7A8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD32F2F), width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFC62828)]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Text('🔊', style: TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SelectableText(
                          audio,
                          style: style.copyWith(fontSize: 13, color: const Color(0xFF6D4C41), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Answer options
              ...options.mapIndexed(
                (index, option) => Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD32F2F), width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFC62828)]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFC107), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D...
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SelectableText(option['text'] ?? '', style: style.copyWith(fontSize: 14, color: const Color(0xFF5D4037))),
                      ),
                    ],
                  ),
                ),
              ),

              // Explanation
              if (explanation != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF59D), Color(0xFFFFEE58)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD32F2F), width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Text('💡', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SelectableText(
                          explanation,
                          style: style.copyWith(color: const Color(0xFF5D4037), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDefaultBotResponse(String? text, List<dynamic> suggestedPrompts, String? summary, TextStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(text ?? '', style: style),
        if (suggestedPrompts.isNotEmpty) ...[const SizedBox(height: 12), _buildSuggestedPrompts(suggestedPrompts, style)],
        if (summary != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFE8CC), Color(0xFFFFD7A8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD32F2F), width: 2),
              boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFC62828)]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('📝', style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableText(summary, style: style.copyWith(color: const Color(0xFF5D4037))),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestedPrompts(List<dynamic> prompts, TextStyle style) => Row(
    children: [
      ...prompts.map(
        (prompt) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFFB300)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD32F2F), width: 2),
              boxShadow: [BoxShadow(color: const Color(0xFFFFC107).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Center(
              child: SelectableText(
                prompt,
                style: style.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  shadows: [const Shadow(color: Color(0xFFD32F2F), blurRadius: 3)],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
