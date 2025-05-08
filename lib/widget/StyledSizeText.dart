import 'package:flutter/material.dart';

class StyledSizeText extends StatelessWidget {
  final String input;
  final bool showMrp;
  final bool showWsp;
  final bool showLabel;

  const StyledSizeText({
    Key? key,
    required this.input,
    required this.showMrp,
    required this.showWsp,
    required this.showLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: _buildStyledSpans(input),
      ),
    );
  }

  List<InlineSpan> _buildStyledSpans(String input) {
    final List<String> parts = input.split(',');
    List<InlineSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i].trim();

      // Extract size label (text before first special character or whitespace)
      String sizeLabel = part;
      String remainingText = '';

      // Find the first special character or space
      int splitIndex = part.indexOf(RegExp(r'[\s:(]'));
      if (splitIndex != -1) {
        sizeLabel = part.substring(0, splitIndex).trim();
        remainingText = part.substring(splitIndex).trim();
      }

      // Add the size label in bold
      spans.add(TextSpan(
        text: sizeLabel,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));

      // Process remaining text based on boolean flags
      if (remainingText.isNotEmpty) {
        String formattedText = '';
        if (showLabel && showMrp && showWsp && remainingText.contains('MRP') && remainingText.contains('WSP')) {
          // Case: L (MRP : 20, WSP : 30)
          formattedText = ' $remainingText';
        } else if (showMrp && showWsp && remainingText.startsWith('(')) {
          // Case: L (20,30)
          var values = remainingText.substring(1, remainingText.length - 1).split(',').map((e) => e.trim()).toList();
          if (values.length >= 2) {
            formattedText = showLabel
                ? ' (MRP: ${values[0]}, WSP: ${values[1]})'
                : ' (${values[0]}, ${values[1]})';
          } else {
            formattedText = ' ($remainingText)';
          }
        } else if (showMrp) {
          // Case: L : 2599
          // Clean up remainingText to remove leading ':' or other characters
          String cleanValue = remainingText.replaceFirst(RegExp(r'^[:\s]+'), '');
          formattedText = showLabel ? ' (MRP: $cleanValue)' : ' ($cleanValue)';
        } else {
          // Fallback for other cases
          formattedText = ' ($remainingText)';
        }
        spans.add(TextSpan(text: formattedText));
      }

      // Add comma and space between parts, except for the last part
      if (i < parts.length - 1) {
        spans.add(const TextSpan(text: ', '));
      }
    }

    return spans;
  }
}