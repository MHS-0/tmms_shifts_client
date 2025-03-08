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
              tooltip: "خروج از حساب",
              icon: Icon(Icons.logout),
              onPressed: () async {
                final user = Preferences.instance().activeUser;
                if (user == null) {
                  context.pop();
                  return;
                }
                try {
                  // FIX
                  // TODO
                  // await NetworkInterface.instance().logout();
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Row(
                          children: [
                            Text("از حساب خارج شدید!"),
                            SizedBox(width: 32),
                            Icon(Icons.check_rounded, size: 80),
                          ],
                        ),
                      );
                    },
                  );
                  await Future.delayed(Duration(seconds: 2));
                  if (!context.mounted) return;
                  context.go("/login");
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
        ],
      ),
    );
  }
}
