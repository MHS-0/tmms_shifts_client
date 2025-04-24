import 'package:flutter/material.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';

class DeleteButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const DeleteButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          onPressed == null ? Colors.grey : Colors.redAccent,
        ),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
      ),
      onPressed: onPressed,
      child: Text(localizations.delete),
    );
  }
}
