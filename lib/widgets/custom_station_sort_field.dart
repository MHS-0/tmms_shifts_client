import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/sort_provider.dart';
import 'package:tmms_shifts_client/widgets/edit_custom_station_sort_dialog.dart';

class CustomStationSortField extends StatelessWidget {
  const CustomStationSortField({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final preferences = context.read<Preferences>();
    final sortState = context.watch<SortProvider>();
    final user = preferences.activeUser;
    if (user == null) return Container();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Helpers.boldText(localizations.customSort),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Icon(Icons.folder_special, size: 40),
              Helpers.getStationGroupSelectionField(context),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: () async {
                    await Helpers.showEditDialogAndHandleResult(
                      context,
                      ChangeNotifierProvider.value(
                        value: context.read<SortProvider>(),
                        child: const EditCustomStationSortDialog(),
                      ),
                    );

                    final instance = NetworkInterface.instance();
                    final result = await instance.getUsersCustomStationsGroup();
                    if (!context.mounted) return;
                    if (result != null) {
                      preferences.activeUser!
                          .updateFromNewGetCustomStationGroup(result);
                      await preferences.setActiveUserNoNotify(user);
                      sortState.setSelectedCustomSort(null);
                      if (!context.mounted) return;
                      Helpers.removeQueryFromPath(context, customSortKey);
                    }
                  },
                  label: Text(localizations.edit),
                  icon: Icon(Icons.edit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
