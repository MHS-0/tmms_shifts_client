import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return FilledButton(
      child: Text(localizations.cancelButtonText),
      onPressed: () {
        context.pop(cancelledMessage);
      },
    );
  }
}
