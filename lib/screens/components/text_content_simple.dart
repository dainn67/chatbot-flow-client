import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// A simplified text content component that renders text with HTML tags,
/// converts markdown-style bold text (**text**) to HTML bold tags,
/// and handles LaTeX math expressions \(expression\).
class TextContentSimple extends StatelessWidget {
  /// The text content to display
  final String inputText;

  /// Text alignment
  final TextAlign textAlign;

  /// Base text style
  final TextStyle style;

  const TextContentSimple({
    super.key,
    required this.inputText,
    this.textAlign = TextAlign.left,
    this.style = const TextStyle(fontSize: 16, height: 1.5),
  });

  @override
  Widget build(BuildContext context) {
    String text = inputText;

    // Split text into segments of normal text and math expressions
    final segments = _splitTextAndMath(text);

    if (segments.length == 1 && !segments.first.isMath) {
      // If there's only one segment and it's not math, use the original logic
      final formattedText = _formatText(segments.first.content);

      if (_containsHtmlTags(formattedText)) {
        return Html(
          data: formattedText,
          style: {
            // Base styling for all elements
            "*": Style.fromTextStyle(style).copyWith(textAlign: textAlign, margin: Margins.only(bottom: 8)),
            // Heading styles
            "h1": Style.fromTextStyle(
              style,
            ).copyWith(fontSize: FontSize(style.fontSize! * 1.8), fontWeight: FontWeight.bold, margin: Margins.only(bottom: 8)),
            "h2": Style.fromTextStyle(
              style,
            ).copyWith(fontSize: FontSize(style.fontSize! * 1.5), fontWeight: FontWeight.bold, margin: Margins.only(bottom: 6)),
            "h3": Style.fromTextStyle(
              style,
            ).copyWith(fontSize: FontSize(style.fontSize! * 1.2), fontWeight: FontWeight.bold, margin: Margins.only(bottom: 4)),
            // Text formatting
            "b": Style.fromTextStyle(style).copyWith(fontWeight: FontWeight.bold, margin: Margins.only(bottom: 8)),
            "strong": Style.fromTextStyle(style).copyWith(fontWeight: FontWeight.bold, margin: Margins.only(bottom: 8)),
            "i": Style.fromTextStyle(style).copyWith(fontStyle: FontStyle.italic, margin: Margins.only(bottom: 8)),
            "em": Style.fromTextStyle(style).copyWith(fontStyle: FontStyle.italic, margin: Margins.only(bottom: 8)),
            "u": Style.fromTextStyle(style).copyWith(textDecoration: TextDecoration.underline, margin: Margins.only(bottom: 8)),
            "p": Style.fromTextStyle(style).copyWith(margin: Margins.only(bottom: 8)),
            "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
          },
          shrinkWrap: true,
        );
      } else {
        return Text(formattedText, style: style, textAlign: textAlign);
      }
    }

    // If we have multiple segments or math expressions, use a Row/Wrap
    return Wrap(
      alignment: textAlign == TextAlign.center
          ? WrapAlignment.center
          : textAlign == TextAlign.right
          ? WrapAlignment.end
          : WrapAlignment.start,
      children: segments.map((segment) {
        if (segment.isMath) {
          double fontSize = segment.content.contains('frac') ? 24 : 18;

          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: Offset(0, 6),
                    child: Math.tex(
                      segment.content,
                      textStyle: style.copyWith(fontSize: fontSize),
                      mathStyle: MathStyle.text,
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          final formattedText = _formatText(segment.content);
          if (_containsHtmlTags(formattedText)) {
            return Html(
              data: formattedText,
              style: {
                "*": Style.fromTextStyle(style).copyWith(textAlign: textAlign, margin: Margins.only(bottom: 8)),
                "b": Style.fromTextStyle(style).copyWith(fontWeight: FontWeight.bold),
                "strong": Style.fromTextStyle(style).copyWith(fontWeight: FontWeight.bold),
                "i": Style.fromTextStyle(style).copyWith(fontStyle: FontStyle.italic),
                "em": Style.fromTextStyle(style).copyWith(fontStyle: FontStyle.italic),
                "u": Style.fromTextStyle(style).copyWith(textDecoration: TextDecoration.underline),
                "p": Style.fromTextStyle(style),
                "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              },
              shrinkWrap: true,
            );
          } else {
            return Text(formattedText, style: style, textAlign: textAlign);
          }
        }
      }).toList(),
    );
  }

  /// Splits text into segments of regular text and math expressions
  List<TextSegment> _splitTextAndMath(String input) {
    final List<TextSegment> segments = [];
    final mathPattern = RegExp(r'\\\((.*?)\\\)');

    int lastIndex = 0;

    for (final match in mathPattern.allMatches(input)) {
      if (match.start > lastIndex) {
        // Add text before the math expression
        segments.add(TextSegment(content: input.substring(lastIndex, match.start), isMath: false));
      }
      // Add the math expression (without the \( \) delimiters)
      segments.add(TextSegment(content: match.group(1)!, isMath: true));
      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      // Add remaining text
      segments.add(TextSegment(content: input.substring(lastIndex), isMath: false));
    }

    return segments;
  }

  /// Formats the text by converting markdown bold to HTML and normalizing HTML tags
  String _formatText(String input) {
    // Convert markdown-style bold (**text**) to HTML bold tags
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');
    var result = input.replaceAllMapped(boldPattern, (match) => '<b>${match.group(1)}</b>');

    final italicPattern = RegExp(r'\*(.*?)\*');
    result = result.replaceAllMapped(italicPattern, (match) => '<i>${match.group(1)}</i>');

    // Handle multiple line breaks by converting them to proper HTML line breaks
    // First convert any series of \n into <br/> tags
    result = _convertNewLinesToHtml(result);

    // Normalize HTML line breaks
    result = result.replaceAll('<br>', '<br/>').replaceAll('<br >', '<br/>').replaceAll('<br  >', '<br/>');

    return result;
  }

  /// Converts newline characters to HTML <br/> tags, preserving multiple line breaks
  String _convertNewLinesToHtml(String input) {
    // Replace consecutive newlines with a marker
    String result = input.replaceAll(RegExp(r'\n{2,}'), '||DOUBLE_LINE_BREAK||');

    // Replace single newlines with <br/>
    result = result.replaceAll('\n', '<br/>');

    // Replace the marker with double <br/> tags
    result = result.replaceAll('||DOUBLE_LINE_BREAK||', '<br/><br/>');

    return result;
  }

  /// Checks if the text contains HTML tags
  bool _containsHtmlTags(String input) {
    final htmlTagPattern = RegExp(r'<[^>]*>');
    return htmlTagPattern.hasMatch(input);
  }
}

/// Represents a segment of text that can be either regular text or a math expression
class TextSegment {
  final String content;
  final bool isMath;

  TextSegment({required this.content, required this.isMath});
}
