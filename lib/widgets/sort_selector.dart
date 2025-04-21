import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/sort_provider.dart';

class SortSelector extends StatefulWidget {
  const SortSelector({super.key});

  @override
  State<SortSelector> createState() => _SortSelectorState();
}

class _SortSelectorState extends State<SortSelector> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final preferences = context.watch<Preferences>();
    final sortState = context.watch<SortProvider>();
    final selectedSort = sortState.selectedSort;

    final isByDateAscSelected = selectedSort == SortSelection.byDateAsc;
    final isByDateDescSelected = selectedSort == SortSelection.byDateDesc;
    final isByStationAscSelected =
        selectedSort == SortSelection.byStationAlphabeticAsc;
    final isByStationDescSelected =
        selectedSort == SortSelection.byStationAlphabeticDesc;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Tooltip(
        message: localizations.itemSort,
        child: Row(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort_rounded, size: 40),
            DropdownMenu(
              initialSelection: selectedSort,
              onSelected: (sort) {
                if (sort == null) return;
                sortState.setSelectedSort(sort);
                Helpers.addQueryToPath(
                  context,
                  sortByKey,
                  SortProvider.sortSelectionToString(sort),
                );
              },
              width: 350,
              hintText: localizations.itemSort,
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  label: localizations.byDateAsc,
                  value: SortSelection.byDateAsc,
                  leadingIcon:
                      isByDateAscSelected
                          ? selectedCheckIcon
                          : unselectedCheckIcon,
                  labelWidget:
                      isByDateAscSelected
                          ? Helpers.boldText(localizations.byDateAsc)
                          : null,
                ),
                DropdownMenuEntry(
                  label: localizations.byDateDesc,
                  value: SortSelection.byDateDesc,
                  leadingIcon:
                      isByDateDescSelected
                          ? selectedCheckIcon
                          : unselectedCheckIcon,
                  labelWidget:
                      isByDateDescSelected
                          ? Helpers.boldText(localizations.byDateDesc)
                          : null,
                ),
                DropdownMenuEntry(
                  label: localizations.byStationAsc,
                  value: SortSelection.byStationAlphabeticAsc,
                  leadingIcon:
                      isByStationAscSelected
                          ? selectedCheckIcon
                          : unselectedCheckIcon,
                  labelWidget:
                      isByStationAscSelected
                          ? Helpers.boldText(localizations.byStationAsc)
                          : null,
                ),
                DropdownMenuEntry(
                  label: localizations.byStationDesc,
                  value: SortSelection.byStationAlphabeticDesc,
                  leadingIcon:
                      isByStationDescSelected
                          ? selectedCheckIcon
                          : unselectedCheckIcon,
                  labelWidget:
                      isByStationDescSelected
                          ? Helpers.boldText(localizations.byStationDesc)
                          : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
