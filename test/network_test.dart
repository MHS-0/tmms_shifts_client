// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/network_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Network and backend related (requests and responses)", () {
    const oneSecDelay = Duration(seconds: 1);
    DioAdapter? dioAdapter;
    NetworkInterface? networkInterface;

    setUpAll(() {
      final dio = Dio(
        BaseOptions(
          // baseUrl: "localhost:8000",
          extra: {"withCredentials": true},
          preserveHeaderCase: true,
        ),
      );
      dioAdapter = DioAdapter(dio: dio);
      networkInterface = NetworkInterface.instance(dio: dio);
    });

    test("Login", () async {
      final req = LoginRequest(username: "admin", password: "1234");

      dioAdapter!.onPost(
        "/user/login",
        (server) {
          server.reply(200, {
            "expiry": "2024-12-09T10:47:26.243088+03:30",
            "token":
                "6b42ba81497dd6dcce0a4dd665f1619843bd460b031258ea7aee0316d5e019f5",
            "user": {"username": "admin", "is_staff": true},
          }, delay: oneSecDelay);
        },
        data: req.toJson(),
        headers: {"Authorization": ""},
      );

      final resp = await networkInterface!.login(req);
      print(resp.toJson());
    });
  });
}
