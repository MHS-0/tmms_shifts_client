import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

class DataFetchError extends StatelessWidget {
  final String content;

  const DataFetchError({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 32,
          children: [
            const Icon(Icons.error),
            Text(content),
            ElevatedButton(
              onPressed: () {
                context.read<Preferences>().refreshRoute();
              },
              child: Text(localizations.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
