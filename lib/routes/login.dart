import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/routes/monitoring_full_report_route.dart';
import 'package:tmms_shifts_client/widgets/success_dialog.dart';
import 'package:tmms_shifts_client/widgets/wait_dialog.dart';

class LoginRoute extends StatefulWidget {
  static const routingName = "login";

  const LoginRoute({super.key});

  @override
  State<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  /// This key will be used to validate the inputs on this page.
  final _formKey = GlobalKey<FormState>();

  /// The textController for the username's TextField
  final _usernameController = TextEditingController();

  /// The textController for the password TextField
  final _passwordController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Helpers.initialRouteSetup(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SelectionArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 72),
            child: Center(
              child: Card(
                color: Theme.of(context).colorScheme.inversePrimary,
                elevation: 16,
                child: Padding(
                  padding: offsetAll32p,
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 16,
                        children: [
                          const SizedBox(height: 50),
                          Image.asset(iconAssetPath, width: 200, height: 200),
                          Text(
                            localizations.longTitle,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(),
                          TextFormField(
                            controller: _usernameController,
                            autofillHints: const [AutofillHints.username],
                            decoration: InputDecoration(
                              constraints: BoxConstraints.loose(
                                Size(300, double.infinity),
                              ),
                              labelText: localizations.usernameTextFieldLabel,
                              hintText: localizations.usernameTextFieldHint,
                            ),
                            textInputAction: TextInputAction.next,
                            autofocus: true,
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.fieldShouldBeFilled;
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _passwordController,
                            autofillHints: const [AutofillHints.password],
                            obscureText: true,
                            decoration: InputDecoration(
                              constraints: BoxConstraints.loose(
                                Size(300, double.infinity),
                              ),
                              labelText: localizations.passwordTextFieldLabel,
                              hintText: localizations.passwordTextFieldHint,
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted:
                                (_) async => await _loginCallback(
                                  context,
                                  localizations,
                                ),
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.fieldShouldBeFilled;
                              }
                              return null;
                            },
                          ),
                          ElevatedButton.icon(
                            label: Text(localizations.sign_in),
                            icon: const Icon(Icons.login),
                            onPressed:
                                () async => await _loginCallback(
                                  context,
                                  localizations,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginCallback(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    if (_formKey.currentState!.validate()) {
      final loginInfo = LoginRequest(
        username: _usernameController.text,
        password: _passwordController.text,
      );
      Helpers.showCustomDialog(context, const WaitDialog());
      final instance = NetworkInterface.instance();

      final loginResp = await instance.login(loginInfo);

      if (!context.mounted) return;

      if (loginResp == null) {
        context.pop();
        Helpers.showNetworkErrorAlertDialog(context, localizations);
        return;
      }

      final profileResp = await instance.getProfile(loginResp.token);

      if (!context.mounted) return;

      if (profileResp == null) {
        context.pop();
        Helpers.showNetworkErrorAlertDialog(context, localizations);
        return;
      }

      context.pop();
      Helpers.showCustomDialog(
        context,
        SuccessDialog(content: localizations.youHaveBeenLoggedIn),
      );

      final activeUser = ActiveUser.fromLoginResponse(loginResp, profileResp);

      // TODO: Remove this maybe?
      // It might look good but it slown down the UX.
      await Future.delayed(Duration(seconds: 1));
      if (!context.mounted) return;
      await context.read<Preferences>().setActiveUser(activeUser);
      // IMPORTANT: Update the used token after the new value is set in preferences.
      NetworkInterface.updateUsedToken();

      if (!context.mounted) return;
      context.pop();
      context.goNamed(MonitoringFullReportRoute.routingName);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
