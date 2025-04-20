// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Network and backend related (requests and responses)", () {
    const oneSecDelay = Duration(seconds: 1);
    late final DioAdapter dioAdapter;
    late final NetworkInterface networkInterface;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({
        activeUserKey: jsonEncode(MockData.mockActiveUser),
      });
      await Preferences.instance().load();
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

    test("Default values/consts", () async {
      assert(authHeaderKey == "Authorization");
      assert(
        DeepCollectionEquality().equals(NetworkInterface.emptyHeaderMap, {
          authHeaderKey: "",
        }),
      );
      assert(
        DeepCollectionEquality().equals(NetworkInterface.filledHeaderMap, {
          authHeaderKey: "Token ${Preferences.instance().activeUser?.token}",
        }),
      );
    });

    test("Login", () async {
      final req = MockData.mockLoginRequest;
      final respJson = MockData.mockLoginResponse.toJson();
      dioAdapter.onPost(
        "/user/login",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        data: req.toJson(),
        headers: NetworkInterface.emptyHeaderMap,
      );

      final respDeserialized = await networkInterface.login(req);
      assert(
        DeepCollectionEquality().equals(respDeserialized!.toJson(), respJson),
      );
    });

    test("Logout", () async {
      dioAdapter.onPost("/user/logout", (server) {
        server.reply(204, null, delay: oneSecDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      await networkInterface.logout();
    });

    test("Get Profile", () async {
      final respJson = MockData.mockGetProfileResponse.toJson();
      dioAdapter.onGet("/user/profile/", (server) {
        server.reply(200, respJson, delay: oneSecDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      final respDeserialized = await networkInterface.getProfile(
        MockData.mockLoginResponse.token,
      );
      assert(
        DeepCollectionEquality().equals(respDeserialized!.toJson(), respJson),
      );
    });

    test("Create Shift Data", () async {
      final req = MockData.mockCreateShiftDataRequest;
      final respJson = MockData.mockCreateShiftDataResponse.toJson();
      dioAdapter.onPost(
        "/pressure_and_temperature/shift/",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        data: req.toJson(),
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await networkInterface.createShiftData(req);
      assert(
        DeepCollectionEquality().equals(respDeserialized!.toJson(), respJson),
      );
    });

    test("Update Shift Data", () async {
      final req = MockData.mockUpdateShiftDataRequest;
      final respJson = MockData.mockUpdateShiftDataResponse.toJson();
      dioAdapter.onPut(
        "/pressure_and_temperature/shift/3/",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        data: req.toJson(),
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await networkInterface.updateShiftData(req, 3);
      assert(
        DeepCollectionEquality().equals(respDeserialized!.toJson(), respJson),
      );
    });

    test("Get Shift Data", () async {
      final respJson = MockData.mockGetShiftDataResponse.toJson();
      dioAdapter.onGet(
        "/pressure_and_temperature/shift/3",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await networkInterface.getShiftData(3);
      assert(
        DeepCollectionEquality().equals(respDeserialized.toJson(), respJson),
      );
    });

    test("Get Shift Last Action", () async {
      final respJson = MockData.mockGetShiftLastActionResponse.toJson();
      dioAdapter.onGet(
        "/pressure_and_temperature/last-action",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await networkInterface.getShiftLastAction();
      assert(
        DeepCollectionEquality().equals(respDeserialized.toJson(), respJson),
      );

      dioAdapter.onGet(
        "/pressure_and_temperature/last-action",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        queryParameters: {"station_codes": "12345"},
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized2 = await networkInterface.getShiftLastAction(
        query: StationsQuery(stationCodes: [12345]),
      );
      assert(
        DeepCollectionEquality().equals(respDeserialized2.toJson(), respJson),
      );
    });

    test("Destroy Shift Data", () async {
      dioAdapter.onDelete(
        "/pressure_and_temperature/shift/3",
        (server) {
          server.reply(204, null, delay: oneSecDelay);
        },
        headers: NetworkInterface.filledHeaderMap,
      );

      await networkInterface.destroyShiftData(3);
    });

    test("Get Shifts Data List", () async {
      final respJson = MockData.mockGetShiftsDataListResponse.toJson();
      dioAdapter.onGet(
        "/pressure_and_temperature/shift",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        queryParameters: {
          "from_date": "1402-01-01",
          "to_date": "1403-02-02",
          "station_codes": "3123,432",
        },
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await networkInterface.getShiftsDataList(
        query: ToFromDateStationsQuery(
          fromDate: "1402-01-01",
          toDate: "1403-02-02",
          stationCodes: [3123, 432],
        ),
      );
      assert(
        DeepCollectionEquality().equals(respDeserialized!.toJson(), respJson),
      );

      dioAdapter.onGet(
        "/pressure_and_temperature/shift",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        queryParameters: {"from_date": "1402-01-01"},
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized2 = await networkInterface.getShiftsDataList(
        query: ToFromDateStationsQuery(fromDate: "1402-01-01"),
      );
      assert(
        DeepCollectionEquality().equals(respDeserialized2!.toJson(), respJson),
      );

      dioAdapter.onGet(
        "/pressure_and_temperature/shift",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized3 = await networkInterface.getShiftsDataList();
      assert(
        DeepCollectionEquality().equals(respDeserialized3!.toJson(), respJson),
      );
    });

    test("Create Corrector", () async {
      final req = MockData.mockCreateCorrectorRequest;
      final respJson = MockData.mockCreateCorrectorResponse.toJson();
      dioAdapter.onPost(
        "/meter_and_corrector/shift/",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        data: req.toJson(),
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await networkInterface.createCorrector(req);
      assert(
        DeepCollectionEquality().equals(respDeserialized.toJson(), respJson),
      );
    });

    test("Update Corrector", () async {
      final req = MockData.mockUpdateCorrectorRequest;
      final respJson = MockData.mockUpdateCorrectorResponse.toJson();
      dioAdapter.onPut(
        "/meter_and_corrector/shift/3/",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        data: req.toJson(),
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await networkInterface.updateCorrector(req, 3);
      assert(
        DeepCollectionEquality().equals(respDeserialized.toJson(), respJson),
      );
    });

    test("Get Corrector Data", () async {
      final respJson = MockData.mockGetCorrectorDataResponse.toJson();
      dioAdapter.onGet("/meter_and_corrector/shift/3/", (server) {
        server.reply(200, respJson, delay: oneSecDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      final respDeserialized = await networkInterface.getCorrectorData(3);
      assert(
        DeepCollectionEquality().equals(respDeserialized.toJson(), respJson),
      );
    });

    test("Get Corrector List Data", () async {
      final respJson = MockData.mockGetCorrectorDataListResponse.toJson();
      dioAdapter.onGet(
        "/meter_and_corrector/shift",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        queryParameters: {"from_date": "1402-01-01", "to_date": "1403-02-02"},
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await networkInterface.getCorrectorDataList(
        query: ToFromDateQuery(toDate: "1403-02-02", fromDate: "1402-01-01"),
      );
      assert(
        DeepCollectionEquality().equals(respDeserialized.toJson(), respJson),
      );

      dioAdapter.onGet(
        "/meter_and_corrector/shift",
        (server) {
          server.reply(200, respJson, delay: oneSecDelay);
        },
        queryParameters: {"from_date": "1402-01-01"},
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized2 = await networkInterface.getCorrectorDataList(
        query: ToFromDateQuery(fromDate: "1402-01-01"),
      );
      assert(
        DeepCollectionEquality().equals(respDeserialized2.toJson(), respJson),
      );

      dioAdapter.onGet("/meter_and_corrector/shift", (server) {
        server.reply(200, respJson, delay: oneSecDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      final respDeserialized3 = await networkInterface.getCorrectorDataList();
      assert(
        DeepCollectionEquality().equals(respDeserialized3.toJson(), respJson),
      );
    });

    test("Destroy Corrector Data", () async {
      dioAdapter.onDelete("/meter_and_corrector/shift/3/", (server) {
        server.reply(204, null, delay: oneSecDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      await networkInterface.deleteCorrectorData(3);
    });
  });
}
