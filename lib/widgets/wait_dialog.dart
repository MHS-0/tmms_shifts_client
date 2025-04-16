import 'package:flutter/material.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';

class WaitDialog extends StatelessWidget {
  const WaitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        spacing: 32,
        children: [
          Text(localizations.pleaseWait),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
