import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';

class ErrorAlertDialog extends StatelessWidget {
  const ErrorAlertDialog(this.error, {super.key, this.isUnknownError = false});

  final Object error;
  final bool isUnknownError;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localizations.errorDialogTitle),
      content:
          isUnknownError
              ? Text(
                "${localizations.errorDialogDescBegin}\n\n$error \n\n${localizations.errorDialogDescEnd}",
              )
              : Text(error.toString()),

      actions: [
        ElevatedButton(
          child: Text(localizations.okButtonText),
          onPressed: () {
            context.pop();
          },
        ),
      ],
    );
  }
}
