import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';

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
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: Center(
              child: Text(
                localizations.title,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          ListTile(
            title: Text(localizations.sign_in),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              Navigator.pop(context);
              context.go("/login");
            },
            style: ListTileStyle.drawer,
          ),
          _divider,
          ListTile(
            title: Text(localizations.settings),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);
              // TODO?
              // Navigator.pushNamed(
              //   context,
              //   SettingsPage.routeName,
              // );
            },
            style: ListTileStyle.drawer,
          ),
          _divider,
          AboutListTile(
            // TODO
            // applicationIcon: Image.asset(iconAssetPath, height: 50),
            applicationName: localizations.title,
            applicationVersion: localizations.appVersion,
            icon: const Icon(Icons.info),
            aboutBoxChildren: [Text(localizations.aboutDescription)],
          ),
        ],
      ),
    );
  }
}
