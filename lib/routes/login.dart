import 'package:flutter/material.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:dio/dio.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({super.key});

  @override
  State<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  /// The textController for the username's TextField
  final _usernameController = TextEditingController();

  /// The textController for the password TextField
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(localizations.sign_in), centerTitle: true),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlutterLogo(size: 250),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      constraints: BoxConstraints.loose(
                        Size(300, double.infinity),
                      ),
                      labelText: localizations.usernameTextFieldLabel,
                      hintText: localizations.usernameTextFieldHint,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        constraints: BoxConstraints.loose(
                          Size(300, double.infinity),
                        ),
                        labelText: localizations.passwordTextFieldLabel,
                        hintText: localizations.passwordTextFieldHint,
                      ),
                      autofocus: true,
                      maxLines: null,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final dio = Dio(BaseOptions(baseUrl: "localhost:8000"));
                    await dio.get("/user/login");
                  },
                  child: Text(localizations.sign_in),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
