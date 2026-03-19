import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:android_control/data/models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _detectLanguage(String code) {
    if (code.contains('import ') && (code.contains('from ') || code.contains('def '))) {
      return 'python';
    }
    if (code.contains('public class') || code.contains('public static void')) {
      return 'java';
    }
    if (code.contains('#include') || code.contains('int main(')) {
      return 'cpp';
    }
    if (code.contains('function') || code.contains('const ') || code.contains('=>')) {
      return 'javascript';
    }
    if (code.startsWith('{') && (code.contains('"') && code.contains(':'))) {
      return 'json';
    }
    if (code.contains('func ') && code.contains('package ')) {
      return 'go';
    }
    if (code.contains('fn ') && code.contains('let mut')) {
      return 'rust';
    }
    return 'plaintext';
  }

  List<Widget> _parseContent(String content) {
    final List<Widget> widgets = [];
    final codeBlockRegex = RegExp(r'```(\w*)\n?([\s\S]*?)```');
    int lastEnd = 0;

    for (final match in codeBlockRegex.allMatches(content)) {
      if (match.start > lastEnd) {
        final text = content.substring(lastEnd, match.start).trim();
        if (text.isNotEmpty) {
          widgets.add(_buildRichText(text));
        }
      }

      final language = match.group(1)?.isNotEmpty == true 
          ? match.group(1)! 
          : _detectLanguage(match.group(2) ?? '');
      final code = (match.group(2) ?? '').trim();

      widgets.add(_buildCodeBlock(code, language));
      lastEnd = match.end;
    }

    if (lastEnd < content.length) {
      final text = content.substring(lastEnd).trim();
      if (text.isNotEmpty) {
        widgets.add(_buildRichText(text));
      }
    }

    if (widgets.isEmpty && content.isNotEmpty) {
      widgets.add(_buildRichText(content));
    }

    return widgets;
  }

  Widget _buildRichText(String text) {
    final spans = _parseMarkdown(text);
    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(
          color: Colors.black87,
          height: 1.4,
          fontSize: 15,
        ),
      ),
    );
  }

  List<InlineSpan> _parseMarkdown(String text) {
    final List<InlineSpan> spans = [];
    final boldRegex = RegExp(r'\*\*(.+?)\*\*');
    final italicRegex = RegExp(r'_(.+?)_');
    final codeRegex = RegExp(r'`(.+?)`');

    int lastEnd = 0;
    final allMatches = <_MarkdownMatch>[];

    for (final match in boldRegex.allMatches(text)) {
      allMatches.add(_MarkdownMatch(match.start, match.end, 'bold', match.group(1)!));
    }
    for (final match in italicRegex.allMatches(text)) {
      allMatches.add(_MarkdownMatch(match.start, match.end, 'italic', match.group(1)!));
    }
    for (final match in codeRegex.allMatches(text)) {
      allMatches.add(_MarkdownMatch(match.start, match.end, 'code', match.group(1)!));
    }

    allMatches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in allMatches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      switch (match.type) {
        case 'bold':
          spans.add(TextSpan(
            text: match.content,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ));
          break;
        case 'italic':
          spans.add(TextSpan(
            text: match.content,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ));
          break;
        case 'code':
          spans.add(TextSpan(
            text: match.content,
            style: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: Colors.grey.shade200,
              color: Colors.black87,
            ),
          ));
          break;
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }

    return spans;
  }

  Widget _buildCodeBlock(String code, String language) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF282C34),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFABB2BF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.copy, size: 14, color: Color(0xFFABB2BF)),
                      SizedBox(width: 4),
                      Text('Copy', style: TextStyle(color: Color(0xFFABB2BF), fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: HighlightView(
              code,
              language: language,
              theme: atomOneDarkTheme,
              textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) {
      return _buildLoadingBubble();
    }

    if (message.error != null) {
      return _buildErrorBubble(context);
    }

    final isUser = message.isUser;
    final contentWidgets = isUser 
        ? [_buildRichText(message.content)]
        : _parseContent(message.content);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...contentWidgets,
            if (message.toolCalls != null && message.toolCalls!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: message.toolCalls!.map((tool) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.build, size: 12, color: Theme.of(context).colorScheme.onSecondaryContainer),
                          const SizedBox(width: 4),
                          Text(tool.name, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (!isUser && (message.toolCalls == null || message.toolCalls!.isEmpty))
              const SizedBox.shrink(),
            // Copy button for all messages
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () => _copyToClipboard(context, message.content),
                child: const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(Icons.copy, size: 18, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('AI is thinking...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkdownMatch {
  final int start;
  final int end;
  final String type;
  final String content;

  _MarkdownMatch(this.start, this.end, this.type, this.content);
}
