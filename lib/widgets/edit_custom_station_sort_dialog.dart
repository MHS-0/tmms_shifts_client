import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/sort_provider.dart';
import 'package:tmms_shifts_client/widgets/cancel_button.dart';
import 'package:tmms_shifts_client/widgets/delete_button.dart';
import 'package:tmms_shifts_client/widgets/ok_button.dart';
import 'package:tmms_shifts_client/widgets/title_and_text_field_row.dart';

class EditCustomStationSortDialog extends StatefulWidget {
  const EditCustomStationSortDialog({super.key});

  @override
  State<EditCustomStationSortDialog> createState() =>
      _EditCustomStationSortDialogState();
}

class _EditCustomStationSortDialogState
    extends State<EditCustomStationSortDialog> {
  final _formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  List<Station> _orderedList = [];
  int? selectedId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderedList = Preferences.instance().activeUser!.stations;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Preferences.instance(),
          key: const ObjectKey(
            "Custom station sort dialog preferences provider",
          ),
        ),
        ChangeNotifierProvider.value(
          value: context.read<SortProvider>(),
          key: const ObjectKey("Custom station sort dialog sort provider"),
        ),
      ],
      child: Builder(
        builder: (context) {
          // So that we can refresh it using the DataFetchError's refresh button
          // if needed.
          final user = context.read<Preferences>().activeUser!;
          final sortState = context.read<SortProvider>();
          final localizations = AppLocalizations.of(context)!;
          final userStations = user.stations;

          final entries =
              user.customStationSort?.map((item) {
                final thisSortIsSelected =
                    (selectedId != null && selectedId == item.id);

                return DropdownMenuEntry(
                  value: item.id,
                  label: item.title,
                  leadingIcon:
                      thisSortIsSelected
                          ? selectedCheckIcon
                          : unselectedCheckIcon,
                  labelWidget:
                      thisSortIsSelected ? Helpers.boldText(item.title) : null,
                );
              }).toList();

          final selectionField = DropdownMenu<int?>(
            initialSelection: selectedId,
            onSelected: (sortId) {
              selectedId = sortId;
              final sort =
                  user.customStationSort
                      ?.where((e) => e.id == sortId)
                      .firstOrNull;
              textController.text = sort?.title ?? "";
              if (sortId == null) {
                _orderedList = user.stations;
              } else {
                if (sort != null) {
                  sort.stations.sort(
                    (a, b) => a.priority.compareTo(b.priority),
                  );
                  List<Station> orderedStations = [];
                  for (final entry in sort.stations) {
                    final station =
                        userStations
                            .where((e) => e.code == entry.station)
                            .firstOrNull;
                    if (station == null) continue;
                    orderedStations.add(station);
                  }
                  orderedStations.addAll(
                    userStations.where(
                      (item) =>
                          !orderedStations.any((e) => item.code == e.code),
                    ),
                  );
                  _orderedList = orderedStations;
                }
              }
              setState(() {});
            },
            width: 300,
            hintText: localizations.customSort,
            dropdownMenuEntries: [
              DropdownMenuEntry(value: null, label: localizations.newReport),
              if (entries != null) ...entries,
            ],
          );

          return AlertDialog(
            title: Text(localizations.newReport),
            content: SizedBox(
              width: 800,
              height: 800,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 16,
                  children: [
                    selectionField,
                    TitleAndTextFieldRow(
                      numbersOnly: false,
                      controller: textController,
                      title: localizations.name,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints.loose(
                        Size(double.infinity, 400),
                      ),
                      child: ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        itemCount: _orderedList.length,
                        itemBuilder: (context, index) {
                          final station = _orderedList[index];
                          return ReorderableDragStartListener(
                            key: ValueKey(station.code),
                            index: index,
                            child: ListTile(
                              leading: const Icon(Icons.list),
                              title: Helpers.boldText(station.title),
                              subtitle: Text(
                                "${localizations.area}: ${station.area}",
                              ),
                            ),
                          );
                        },
                        prototypeItem: ListTile(),
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          // await Future.delayed(const Duration(milliseconds: 300));
                          setState(() {
                            final item = _orderedList.removeAt(oldIndex);
                            _orderedList.insert(newIndex, item);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            actions: [
              DeleteButton(
                onPressed:
                    selectedId != null
                        ? () async {
                          final id = selectedId;
                          if (id == null) return;
                          final instance = NetworkInterface.instance();
                          final result = await instance
                              .removeCustomStationGroup(id);

                          if (!context.mounted) return;
                          if (result == null) {
                            context.pop(instance.lastErrorUserFriendly);
                          } else {
                            context.pop();
                          }
                        }
                        : null,
              ),
              OkButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final id = selectedId;
                    final instance = NetworkInterface.instance();

                    Object? result;
                    if (id != null) {
                      // IMPORTANT:
                      // FIXME: put/update method isn't present in postman. ask backend.
                      // result = await instance.(
                      //   PutUpdateCorrectorChangeEventRequest(
                      //     id: item.id,
                      //     oldMeterAmount: oldMeter,
                      //     newMeterAmount: newMeter,
                      //     ran: item.ran,
                      //     date: item.date,
                      //     oldCorrectorAmount: oldCorrector,
                      //     newCorrectorAmount: newCorrector,
                      //     ranSequence: item.ranSequence,
                      //     user: item.user,
                      //     registeredDatetime: item.registeredDatetime,
                      //     stationCode: item.stationCode,
                      //   ),
                      // );
                    } else {
                      result = await instance.createNewStationsGroup(
                        PostCreateNewStationGroupRequest(
                          user: user.username,
                          title: textController.text,
                          stations:
                              _orderedList.indexed
                                  .map(
                                    (e) => StationGroupDataStructure(
                                      priority: e.$1,
                                      station: e.$2.code,
                                    ),
                                  )
                                  .toList(),
                        ),
                      );
                    }
                    if (context.mounted && result == null) {
                      context.pop(instance.lastErrorUserFriendly);
                    } else if (context.mounted) {
                      context.pop();
                    }
                  }
                },
              ),
              const CancelButton(),
            ],
          );
        },
      ),
    );
  }
}
