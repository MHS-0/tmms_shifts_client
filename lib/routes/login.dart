import 'package:dio/dio.dart';
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
import 'package:tmms_shifts_client/widgets/error_alert_dialog.dart';
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
                          obscureText: true,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            constraints: BoxConstraints.loose(
                              Size(300, double.infinity),
                            ),
                            labelText: localizations.passwordTextFieldLabel,
                            hintText: localizations.passwordTextFieldHint,
                          ),
                          textInputAction: TextInputAction.done,
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
                          onPressed: () async {
                            final loginInfo = LoginRequest(
                              username: _usernameController.text,
                              password: _passwordController.text,
                            );
                            if (_formKey.currentState!.validate()) {
                              try {
                                Helpers.showCustomDialog(context, WaitDialog());
                                // TODO
                                // FIX: Actually implement it with the final backend responses.
                                //
                                // final loginResp =
                                //     await NetworkInterface.instance().login(
                                //       loginInfo,
                                //     );
                                // final profileResp =
                                //     await NetworkInterface.instance()
                                //         .getProfile(loginResp.token);
                                // final activeUser = ActiveUser(
                                //   username: profileResp.username,
                                //   password: _passwordController.text,
                                //   token: loginResp.token,
                                //   isStaff: profileResp.isStaff,
                                //   expiry: loginResp.expiry,
                                //   stations: profileResp.stations,
                                // );
                                //
                                // FIX: Actually implement it with the final backend responses.
                                await Future.delayed(Duration(seconds: 3));

                                // FIX: REMOVE before production deploy.
                                final mockActiveUser = MockData.mockActiveUser;

                                if (!context.mounted) return;
                                context.pop();
                                Helpers.showCustomDialog(
                                  context,
                                  SuccessDialog(
                                    content: localizations.youHaveBeenLoggedIn,
                                  ),
                                );
                                await Future.delayed(Duration(seconds: 2));
                                if (!context.mounted) return;
                                await context.read<Preferences>().setActiveUser(
                                  mockActiveUser,
                                );
                                if (!context.mounted) return;
                                context.pop();
                                context.goNamed(
                                  MonitoringFullReportRoute.routingName,
                                );
                              } on DioException catch (e) {
                                if (e.response?.statusCode == 400) {
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ErrorAlertDialog(
                                          localizations
                                              .invalidUsernameOrPassword,
                                        );
                                      },
                                    );
                                  }
                                  return;
                                }

                                // Handle other network errors too, besides invalid auth
                                if (context.mounted) {
                                  Helpers.showCustomDialog(
                                    context,
                                    ErrorAlertDialog(
                                      "${localizations.logInFailed} \n $e",
                                    ),
                                    barrierDismissable: true,
                                  );
                                }
                                return;
                              } catch (e) {
                                // Handle other kinds of errors besides network ones.
                                // For example, failure in deserialization of the response.
                                if (context.mounted) {
                                  Helpers.showCustomDialog(
                                    context,
                                    ErrorAlertDialog(
                                      "${localizations.logInFailed} \n $e",
                                      isUnknownError: true,
                                    ),
                                    barrierDismissable: true,
                                  );
                                }
                                return;
                              }
                            }
                          },
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
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
