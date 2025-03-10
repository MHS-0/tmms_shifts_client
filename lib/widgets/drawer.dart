import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/routes/counter_corrector_reports.dart';
import 'package:tmms_shifts_client/routes/login.dart';
import 'package:tmms_shifts_client/routes/main_route.dart';
import 'package:tmms_shifts_client/widgets/error_alert_dialog.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  static const _divider = Divider(
    color: Colors.grey,
    indent: 10,
    endIndent: 10,
  );

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = context.read<Preferences>().activeUser;
    if (user == null) return Drawer();

    return Drawer(
      child: ListView(
        children: [
          InkWell(
            onTap: () {
              final routerState = GoRouter.of(context).state;
              if (routerState.name != "home") {
                context.goNamed(MainRoute.routingName);
              } else {
                context.pop();
              }
            },
            child: DrawerHeader(
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
                  await Preferences.instance().unsetActiveUser();
                  if (!context.mounted) return;
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
                  context.pop();
                  context.goNamed(LoginRoute.routingName);
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
                  context.goNamed(LoginRoute.routingName);
                }
              },
            ),
          ),
          MyDrawer._divider,
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
              ListTile(
                leading: Icon(Icons.report),
                title: Text("گزارش کنتور و تصحیح کننده"),
                onTap: () {
                  final routingState = GoRouter.of(context).state;
                  if (routingState.name !=
                      CounterCorrectorReportsRoute.routingName) {
                    context.goNamed(CounterCorrectorReportsRoute.routingName);
                  } else {
                    context.pop();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
