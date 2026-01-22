import 'package:flutter/material.dart';

class ConversationItem extends StatelessWidget {
  final String appName;
  final String flowTitle;
  final bool isSelected;
  final VoidCallback onTap;

  const ConversationItem({super.key, required this.appName, required this.flowTitle, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.3) : Colors.transparent, width: 1.5),
              boxShadow: isSelected
                  ? [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                        : null,
                    color: isSelected ? null : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Icon(Icons.chat_rounded, size: 20, color: isSelected ? Colors.white : const Color(0xFF9CA3AF)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF374151),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        flowTitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
