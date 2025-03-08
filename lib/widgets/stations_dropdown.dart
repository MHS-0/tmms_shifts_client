import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

class StationsDropDown extends StatelessWidget {
  final void Function(String?)? onSelected;

  const StationsDropDown({super.key, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.read<Preferences>().activeUser;
    if (user == null) return Container();

    return Consumer<Preferences>(
      builder: (_, preferences, _) {
        return DropdownMenu(
          onSelected: onSelected,
          width: 300,
          hintText: localizations.chooseStation,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: "همه", label: "همه"),
            ...user.stations.map(
              (item) => DropdownMenuEntry(value: item.code, label: item.title),
            ),
          ],
        );
      },
    );
  }
}
