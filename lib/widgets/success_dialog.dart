import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String content;

  const SuccessDialog({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        spacing: 32,
        children: [Text(content), const Icon(Icons.check_rounded, size: 80)],
      ),
    );
  }
}
