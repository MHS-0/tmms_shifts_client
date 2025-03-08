import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/widgets/error_alert_dialog.dart';

class LoginRoute extends StatefulWidget {
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
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SelectionArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 72),
            child: Center(
              child: Card(
                color: Theme.of(context).colorScheme.inversePrimary,
                elevation: 16,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 50),
                        Image.asset(iconAssetPath, width: 200, height: 200),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
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
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            child: TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                constraints: BoxConstraints.loose(
                                  Size(300, double.infinity),
                                ),
                                labelText: localizations.passwordTextFieldLabel,
                                hintText: localizations.passwordTextFieldHint,
                              ),
                              maxLines: 1,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return localizations.fieldShouldBeFilled;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final loginInfo = LoginRequest(
                              username: _usernameController.text,
                              password: _passwordController.text,
                            );
                            if (_formKey.currentState!.validate()) {
                              try {
                                final resp = await NetworkInterface.instance()
                                    .login(loginInfo);
                                // FIX: Actually implement it with the final backend responses.
                                // if (context.mounted) {
                                //   context.read<Preferences>().setActiveUser(
                                //     resp,
                                //     _passwordController.text,
                                //   );
                                //   context.go("/");
                                // }
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
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ErrorAlertDialog(
                                        e,
                                        isUnknownError: true,
                                      );
                                    },
                                  );
                                }
                                return;
                              } catch (e) {
                                // Handle other kinds of errors besides network ones.
                                // For example, failure in deserialization of the response.
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ErrorAlertDialog(
                                        e,
                                        isUnknownError: true,
                                      );
                                    },
                                  );
                                }
                                return;
                              }
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              Icon(Icons.login),
                              Text(localizations.sign_in),
                            ],
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
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
