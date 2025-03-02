import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';

class NetworkInterface extends ChangeNotifier {
  static final dio = Dio(BaseOptions(baseUrl: "localhost:8000"));

  /// Private constructor to use when instantiating an instance inside the file.
  NetworkInterface._privateConstructor();

  /// The singleton instance of this class
  static final NetworkInterface _interface =
      NetworkInterface._privateConstructor();

  Future<void> login(LoginRequest loginInfo) async {
    await dio.post(
      "/user/login",
      options: Options(
        headers: {"Authorization": null},
        preserveHeaderCase: true,
      ),
      data: loginInfo.toJson(),
    );
  }

  /// The factory that returns the singleton instance.
  factory NetworkInterface.instance() => _interface;
}
