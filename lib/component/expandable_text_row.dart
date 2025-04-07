import 'package:flutter/material.dart';

class ExpandableTextRow extends StatefulWidget {
  final String name;
  final String desc;

  const ExpandableTextRow({super.key, required this.name, required this.desc});

  @override
  State<ExpandableTextRow> createState() => _ExpandableTextRowState();
}

class _ExpandableTextRowState extends State<ExpandableTextRow> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textStyle = textTheme.bodyLarge?.copyWith(fontSize: 14);
    final screenWidth = MediaQuery.of(context).size.width * 0.8;
    String truncatedText = widget.desc;

    TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.desc, style: textStyle),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: screenWidth);

    if (textPainter.didExceedMaxLines) {
      int maxLength = _findMaxChars(widget.desc, textStyle!, screenWidth);
      truncatedText = "${widget.desc.substring(0, maxLength)}... more";
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${widget.name} ",
                    style: textStyle?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: isExpanded ? widget.desc : truncatedText,
                    style: textStyle,
                  ),
                ],
              ),
              maxLines: isExpanded ? null : 2,
              overflow:
                  isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  int _findMaxChars(String text, TextStyle textStyle, double maxWidth) {
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 2,
    );

    for (int i = text.length; i > 0; i--) {
      textPainter.text = TextSpan(text: text.substring(0, i), style: textStyle);
      textPainter.layout(maxWidth: maxWidth);
      if (!textPainter.didExceedMaxLines) {
        return i - 5;
      }
    }
    return text.length;
  }
}
