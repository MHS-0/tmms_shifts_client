import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/widgets/error_alert_dialog.dart';

class ExcelExportButton extends StatelessWidget {
  final List<Object?> data;
  final List<Station> stations;

  const ExcelExportButton({
    super.key,
    required this.data,
    required this.stations,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.read<Preferences>().activeUser;
    if (user == null || user.stations.isEmpty) return Container();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 50,
          width: 165,
          child: FilledButton.icon(
            label: Text(localizations.exportToExcel),
            icon: Icon(Icons.calculate),
            onPressed: () async {
              try {
                final Uint8List bytes;
                if (data.runtimeType ==
                    List<GetMonitoringFullReportResponseResultItem>) {
                  bytes = await Helpers.exportToExcelBytesForMonitoring(
                    data as List<GetMonitoringFullReportResponseResultItem>,
                    stations,
                    localizations,
                  );
                } else {
                  // IMPORTANT:
                  // FIXME
                  bytes = await Helpers.exportToExcelBytes(
                    data as List<Map<String, dynamic>>,
                    localizations,
                  );
                }
                await FilePicker.platform.saveFile(
                  fileName: "output.xlsx",
                  type: FileType.custom,
                  allowedExtensions: ["xlsx"],
                  dialogTitle: localizations.pleaseSelectOutputFile,
                  bytes: bytes,
                );
              } catch (e) {
                if (context.mounted) {
                  await Helpers.showCustomDialog(
                    context,
                    ErrorAlertDialog("${localizations.failedToSaveFile}:\n$e"),
                    barrierDismissable: true,
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
