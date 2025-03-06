import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

class StationsDropDown extends StatelessWidget {
  const StationsDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.read<Preferences>().activeUser;
    if (user == null) return Container();

    return Consumer<Preferences>(
      builder: (_, preferences, _) {
        return DropdownMenu(
          width: 300,
          hintText: localizations.chooseStation,
          dropdownMenuEntries:
              user.stations
                  .map(
                    (item) =>
                        DropdownMenuEntry(value: item.code, label: item.name),
                  )
                  .toList(),
        );
      },
    );
  }
}
