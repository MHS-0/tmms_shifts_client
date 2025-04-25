import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

class NewReportButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NewReportButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    context.read<Preferences>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 50,
          width: 165,
          child: FilledButton.icon(
            label: Text(localizations.newReport),
            icon: Icon(Icons.add),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
