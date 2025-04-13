import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';

class OkButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const OkButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ElevatedButton(
      onPressed:
          onPressed ??
          () {
            context.pop();
          },
      child: Text(localizations.okButtonText),
    );
  }
}
