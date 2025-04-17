import 'package:flutter/material.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/widgets/ok_button.dart';

class ErrorAlertDialog extends StatelessWidget {
  const ErrorAlertDialog(this.error, {super.key, this.isUnknownError = false});

  final Object error;
  final bool isUnknownError;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.errorDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isUnknownError
                ? Text(
                  "${localizations.errorDialogDescBegin}\n\n$error \n\n${localizations.errorDialogDescEnd}",
                )
                : Text("$error"),
          ],
        ),
      ),

      actions: [const OkButton()],
    );
  }
}
