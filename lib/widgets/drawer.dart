import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/widgets/error_alert_dialog.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  static const _divider = Divider(
    color: Colors.grey,
    indent: 10,
    endIndent: 10,
  );

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.read<Preferences>().activeUser;
    if (user == null) return Drawer();

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(iconAssetPath, width: 100, height: 100),
                  Text(
                    localizations.longTitle,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 20,
              child: Image.asset(userIconAssetPath),
            ),
            title: Text(context.read<Preferences>().activeUser!.username),
            // TODO: Replace with some actual relevant data?
            subtitle: user.fullname != null ? Text(user.fullname!) : null,
            trailing: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                final user = Preferences.instance().activeUser;
                if (user == null) return;
                context.pop();
                try {
                  await NetworkInterface.instance().logout();
                } on DioException catch (e) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ErrorAlertDialog(e, isUnknownError: true);
                      },
                    );
                  }
                  return;
                } catch (e) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ErrorAlertDialog(e, isUnknownError: true);
                      },
                    );
                  }
                  return;
                }
                if (context.mounted) {
                  context.read<Preferences>().unsetActiveUser();
                  context.go("/login");
                }
              },
            ),
          ),
          _divider,
          ExpansionTile(
            leading: Icon(Icons.info),
            title: Text(localizations.reports),
            children: [
              ListTile(
                leading: Icon(Icons.add),
                title: Text(localizations.reportPressureAndTemp),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text(localizations.reportCorrectorNumbers),
                onTap: () {},
              ),
            ],
          ),
          ExpansionTile(
            childrenPadding: EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(Icons.data_exploration),
            title: Text(localizations.dataEntry),
            children: [
              SizedBox(height: 8),
              Text(
                localizations.dataPressureAndTempEntry,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              DropdownMenu(
                width: 200,
                label: Text(localizations.station),
                dropdownMenuEntries: [],
              ),
              SizedBox(height: 16),
              Text(
                localizations.dataCounterEntry,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              DropdownMenu(
                width: 200,
                label: Text(localizations.station),
                dropdownMenuEntries: [],
              ),
              SizedBox(height: 16),
              Text(
                localizations.dataCounterReplacementEventEntry,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              DropdownMenu(
                width: 200,
                label: Text(localizations.station),
                enableFilter: true,
                inputDecorationTheme: InputDecorationTheme(filled: true),
                dropdownMenuEntries: [],
              ),
              SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
