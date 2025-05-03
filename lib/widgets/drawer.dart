import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/routes/corrector_replacement_events.dart';
import 'package:tmms_shifts_client/routes/counter_corrector_reports.dart';
import 'package:tmms_shifts_client/routes/counter_replacement_events.dart';
import 'package:tmms_shifts_client/routes/login.dart';
import 'package:tmms_shifts_client/routes/monitoring_full_report_route.dart';
import 'package:tmms_shifts_client/routes/pressure_and_temp_reports_route.dart';
import 'package:tmms_shifts_client/widgets/error_alert_dialog.dart';
import 'package:tmms_shifts_client/widgets/success_dialog.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
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
          InkWell(
            onTap:
                () => navigateIfNotCurrentPage(
                  MonitoringFullReportRoute.routingName,
                ),
            child: SizedBox(
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(iconAssetPath, width: 75, height: 75),
                    SizedBox(
                      height: 40,
                      child: Text(
                        localizations.longTitle,
                        style: const TextStyle(fontSize: 20),
                      ),
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
            title: Text(user.username),
            // TODO: Replace with some actual relevant data?
            subtitle: Text(user.fullname ?? ""),
            trailing: IconButton(
              tooltip: localizations.logout,
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final networkInterface = NetworkInterface.instance();
                final result = await networkInterface.logout();
                if (!context.mounted) return;

                if (result == null) {
                  Helpers.showNetworkErrorAlertDialog(context, localizations);
                }
                try {
                  // FIX
                  // TODO
                  // await NetworkInterface.instance().logout();
                  if (!context.mounted) return;
                  Helpers.showCustomDialog(
                    context,
                    SuccessDialog(content: localizations.youHaveBeenLoggedOut),
                  );
                  await Future.delayed(Duration(seconds: 2));
                  await Preferences.instance().unsetActiveUser();
                  if (!context.mounted) return;
                  context.pop();
                  context.goNamed(LoginRoute.routingName);

                  // Specific errors for network issues can be used with the below line:
                  // on DioException catch (e) {
                  //
                  // In case we want to implement specific error dialogs for those cases in the
                  // future.
                } catch (e) {
                  if (context.mounted) {
                    Helpers.showCustomDialog(
                      context,
                      ErrorAlertDialog(e, isUnknownError: true),
                      barrierDismissable: true,
                    );
                  }
                  return;
                }
              },
            ),
          ),
          _divider,
          ListTile(
            leading: const Icon(Icons.thermostat_rounded),
            title: Text(localizations.reportPressureAndTemp),
            onTap:
                () => navigateIfNotCurrentPage(
                  PressureAndTempReportsRoute.routingName,
                ),
          ),
          ListTile(
            leading: const Icon(Icons.numbers),
            title: Text(localizations.reportCorrectorNumbers),
            onTap:
                () => navigateIfNotCurrentPage(
                  CounterCorrectorReportsRoute.routingName,
                ),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(localizations.reportCounterChangeEvents),
            onTap:
                () => navigateIfNotCurrentPage(
                  CounterReplacementEventsRoute.routingName,
                ),
          ),
          ListTile(
            leading: const Icon(Icons.sync_alt),
            title: Text(localizations.reportCorrectorChangeEvents),
            onTap:
                () => navigateIfNotCurrentPage(
                  CorrectorReplacementEventsRoute.routingName,
                ),
          ),
        ],
      ),
    );
  }

  void navigateIfNotCurrentPage(String routeName) {
    final routingState = GoRouter.of(context).state;
    if (routingState.name != routeName) {
      context.goNamed(routeName);
    } else {
      context.pop();
    }
  }
}
