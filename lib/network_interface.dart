import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

const authHeaderKey = "Authorization";

class NetworkInterface extends ChangeNotifier {
  static final dio = Dio(
    BaseOptions(baseUrl: "localhost:8000", extra: {"withCredentials": true}),
  );

  /// Private constructor to use when instantiating an instance inside the file.
  NetworkInterface._privateConstructor();

  /// The singleton instance of this class
  static final NetworkInterface _interface =
      NetworkInterface._privateConstructor();

  Future<LoginResponse> login(LoginRequest loginInfo) async {
    final Response<Map<String, dynamic>> resp = await dio.post(
      "/user/login",
      options: Options(headers: {authHeaderKey: ""}, preserveHeaderCase: true),
      data: loginInfo.toJson(),
    );
    final finalResp = LoginResponse.fromJson(resp.data!);
    return finalResp;
  }

  Future<void> logout() async {
    await dio.post(
      "/user/logout",
      options: Options(
        headers: {
          authHeaderKey: "Token ${Preferences.instance().activeUser?.token}",
        },
        preserveHeaderCase: true,
      ),
    );
  }

  /// The factory that returns the singleton instance.
  factory NetworkInterface.instance() => _interface;
}
