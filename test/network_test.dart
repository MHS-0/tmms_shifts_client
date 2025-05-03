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

final globalDio = Dio(
  BaseOptions(extra: {"withCredentials": true}, preserveHeaderCase: true),
);
final globalNetworkInterface = NetworkInterface.instance(dio: globalDio);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Network and backend related (requests and responses)", () {
    const customDelay = Duration(milliseconds: 0);
    final dioAdapter = DioAdapter(dio: globalDio);

    setUpAll(() async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({
        activeUserKey: jsonEncode(MockData.mockActiveUser),
      });
      await Preferences.instance().load();
      // To initialize the Dio instance.
      // TODO: Do it cleaner.
      globalNetworkInterface.dio;
    });

    test("Default values/consts", () async {
      assert(authHeaderKey == "Authorization");
      assert(contentTypeKey == "Content-Type");
      assert(applicationJsonValue == "application/json");
      assert(
        DeepCollectionEquality().equals(NetworkInterface.emptyHeaderMap, {
          contentTypeKey: applicationJsonValue,
          authHeaderKey: "",
        }),
      );
      assert(
        DeepCollectionEquality().equals(NetworkInterface.filledHeaderMap, {
          contentTypeKey: applicationJsonValue,
          authHeaderKey: "Token ${Preferences.instance().activeUser?.token}",
        }),
      );
    });

    test("Login", () async {
      final req = MockData.mockLoginRequest;
      final respJson = MockData.mockLoginResponse.toJson();
      dioAdapter.onPost(
        "/user/login/",
        (server) {
          server.reply(200, respJson, delay: customDelay);
        },
        data: req.toJson(),
        headers: NetworkInterface.emptyHeaderMap,
      );

      final respDeserialized = await globalNetworkInterface.login(req);
      assert(
        DeepCollectionEquality().equals(respDeserialized!.toJson(), respJson),
      );
    });

    test("Logout", () async {
      dioAdapter.onPost("/user/logout", (server) {
        server.reply(204, null, delay: customDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      await globalNetworkInterface.logout();
    });

    test("Get Profile", () async {
      final respJson = MockData.mockGetProfileResponse.toJson();
      dioAdapter.onGet("/user/profile/", (server) {
        server.reply(200, respJson, delay: customDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      final respDeserialized = await globalNetworkInterface.getProfile(
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
          server.reply(200, respJson, delay: customDelay);
        },
        data: req.toJson(),
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await globalNetworkInterface.createShiftData(
        req,
      );
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
          server.reply(200, respJson, delay: customDelay);
        },
        data: req.toJson(),
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await globalNetworkInterface.updateShiftData(
        req,
        3,
      );
      assert(
        DeepCollectionEquality().equals(respDeserialized!.toJson(), respJson),
      );
    });

    test("Get Shift Data", () async {
      final respJson = MockData.mockGetShiftDataResponse.toJson();
      dioAdapter.onGet(
        "/pressure_and_temperature/shift/3/",
        (server) {
          server.reply(200, respJson, delay: customDelay);
        },
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await globalNetworkInterface.getShiftData(3);
      assert(
        DeepCollectionEquality().equals(respDeserialized.toJson(), respJson),
      );
    });

    test("Get Shift Last Action", () async {
      final respJson = MockData.mockGetShiftLastActionResponse.toJson();
      dioAdapter.onGet(
        "/pressure_and_temperature/last-action/",
        (server) {
          server.reply(200, respJson, delay: customDelay);
        },
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized =
          await globalNetworkInterface.getShiftLastAction();
      assert(
        DeepCollectionEquality().equals(respDeserialized.toJson(), respJson),
      );

      dioAdapter.onGet(
        "/pressure_and_temperature/last-action/",
        (server) {
          server.reply(200, respJson, delay: customDelay);
        },
        queryParameters: {"station_codes": "12345"},
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized2 = await globalNetworkInterface.getShiftLastAction(
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
          server.reply(204, null, delay: customDelay);
        },
        headers: NetworkInterface.filledHeaderMap,
      );

      await globalNetworkInterface.destroyShiftData(3);
    });

    test("Get Shifts Data List", () async {
      final respJson = MockData.mockGetShiftsDataListResponse.toJson();
      dioAdapter.onGet(
        "/pressure_and_temperature/shift",
        (server) {
          server.reply(200, respJson, delay: customDelay);
        },
        queryParameters: {
          "from_date": "1402-01-01",
          "to_date": "1403-02-02",
          "station_codes": "3123,432",
        },
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await globalNetworkInterface.getShiftsDataList(
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
          server.reply(200, respJson, delay: customDelay);
        },
        queryParameters: {"from_date": "1402-01-01"},
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized2 = await globalNetworkInterface.getShiftsDataList(
        query: ToFromDateStationsQuery(fromDate: "1402-01-01"),
      );
      assert(
        DeepCollectionEquality().equals(respDeserialized2!.toJson(), respJson),
      );

      dioAdapter.onGet(
        "/pressure_and_temperature/shift",
        (server) {
          server.reply(200, respJson, delay: customDelay);
        },
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized3 =
          await globalNetworkInterface.getShiftsDataList();
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
          server.reply(200, respJson, delay: customDelay);
        },
        data: req.toJson(),
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await globalNetworkInterface.createCorrector(
        req,
      );
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
          server.reply(200, respJson, delay: customDelay);
        },
        data: req.toJson(),
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await globalNetworkInterface.updateCorrector(
        req,
        3,
      );
      assert(
        DeepCollectionEquality().equals(respDeserialized.toJson(), respJson),
      );
    });

    test("Get Corrector Data", () async {
      final respJson = MockData.mockGetCorrectorDataResponse.toJson();
      dioAdapter.onGet("/meter_and_corrector/shift/3/", (server) {
        server.reply(200, respJson, delay: customDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      final respDeserialized = await globalNetworkInterface.getCorrectorData(3);
      assert(
        DeepCollectionEquality().equals(respDeserialized.toJson(), respJson),
      );
    });

    test("Get Corrector List Data", () async {
      final respJson = MockData.mockGetCorrectorDataListResponse.toJson();
      dioAdapter.onGet(
        "/meter_and_corrector/shift",
        (server) {
          server.reply(200, respJson, delay: customDelay);
        },
        queryParameters: {"from_date": "1402-01-01", "to_date": "1403-02-02"},
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized = await globalNetworkInterface
          .getCorrectorDataList(
            query: ToFromDateQuery(
              toDate: "1403-02-02",
              fromDate: "1402-01-01",
            ),
          );
      assert(
        DeepCollectionEquality().equals(respDeserialized.toJson(), respJson),
      );

      dioAdapter.onGet(
        "/meter_and_corrector/shift",
        (server) {
          server.reply(200, respJson, delay: customDelay);
        },
        queryParameters: {"from_date": "1402-01-01"},
        headers: NetworkInterface.filledHeaderMap,
      );

      final respDeserialized2 = await globalNetworkInterface
          .getCorrectorDataList(query: ToFromDateQuery(fromDate: "1402-01-01"));
      assert(
        DeepCollectionEquality().equals(respDeserialized2.toJson(), respJson),
      );

      dioAdapter.onGet("/meter_and_corrector/shift", (server) {
        server.reply(200, respJson, delay: customDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      final respDeserialized3 =
          await globalNetworkInterface.getCorrectorDataList();
      assert(
        DeepCollectionEquality().equals(respDeserialized3.toJson(), respJson),
      );
    });

    test("Destroy Corrector Data", () async {
      dioAdapter.onDelete("/meter_and_corrector/shift/3/", (server) {
        server.reply(204, null, delay: customDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      await globalNetworkInterface.deleteCorrectorData(3);
    });
  });
}

final class MockData {
  static final mockLoginRequest = LoginRequest.fromJson({
    "username": "admin",
    "password": "abc123!@#",
  });

  static final mockLoginResponse = LoginResponse.fromJson({
    "expiry": "2026-12-09T10:47:26.243088+03:30",
    "token": "6b42ba81497dd6dcce0a4dd665f1619843bd460b031258ea7aee0316d5e019f5",
    "user": {"username": "admin", "is_staff": true},
  });

  static final mockGetProfileResponse = GetProfileResponse.fromJson({
    "username": "test1",
    "fullname": "کاربر سمنان",
    "stations": [
      {
        "code": 31141050000010,
        "rans": [
          {
            "code": 311410500000101,
            "sequence_number": 1,
            "station": 31141050000010,
          },
          {
            "code": 311410500000102,
            "sequence_number": 2,
            "station": 31141050000010,
          },
          {
            "code": 311410500000103,
            "sequence_number": 3,
            "station": 31141050000010,
          },
        ],
        "type_name": "CGS",
        "title": "مهدیشهر",
        "district": "مهدی شهر",
        "area": "منطقه ۳",
        "capacity": 30000,
        "type": 3,
        "activity": 1,
      },
      {
        "code": 31101050000142,
        "rans": [
          {
            "code": 311010500001421,
            "sequence_number": 1,
            "station": 31101050000142,
          },
          {
            "code": 311010500001422,
            "sequence_number": 2,
            "station": 31101050000142,
          },
          {
            "code": 311010500001423,
            "sequence_number": 3,
            "station": 31101050000142,
          },
        ],
        "type_name": "CGS",
        "title": "شهرک صنعتی سمنان",
        "district": "سمنان",
        "area": "منطقه ۳",
        "capacity": 50000,
        "type": 3,
        "activity": 1,
      },
    ],
    "is_staff": false,
  });

  static final mockActiveUser = ActiveUser.fromLoginResponse(
    mockLoginResponse,
    mockGetProfileResponse,
  );

  // Same structure as the login request
  static final mockLogoutRequest = mockLoginRequest;

  static final mockCreateShiftDataRequest = CreateShiftDataRequest.fromJson({
    "station": 31141050000010,
    "shift": "12",
    "input_pressure": 100,
    "output_pressure": 150,
    "input_temperature": 3000,
    "output_temperature": 2300,
    "date": "1403-11-11",
  });

  static final mockCreateShiftDataResponse = CreateShiftDataResponse.fromJson({
    "date": "1403-11-11",
    "registered_datetime": null,
    "shift": "12",
    "input_pressure": 100,
    "output_pressure": 150,
    "input_temperature": 3000,
    "output_temperature": 2300,
    "station": 12345,
    "user": null,
  });

  static final mockUpdateShiftDataRequest = UpdateShiftDataRequest.fromJson({
    "station": 12345,
    "shift": "24",
    "input_pressure": 10,
    "output_pressure": 10,
    "input_temperature": 30,
    "output_temperature": 23,
    "date": "1403-11-09",
  });

  static final mockUpdateShiftDataResponse = UpdateShiftDataResponse.fromJson({
    "id": 3,
    "date": "1403-11-09",
    "registered_datetime": " 1403-09-11 10:35:56",
    "shift": "24",
    "input_pressure": 10,
    "output_pressure": 10,
    "input_temperature": 30,
    "output_temperature": 23,
    "station": 12345,
    "user": "test",
  });

  static final mockGetShiftDataResponse = GetShiftDataResponse.fromJson({
    "id": 3,
    "date": "1403-11-09",
    "registered_datetime": "1403-09-11 10:35:56",
    "shift": "24",
    "input_pressure": 10,
    "output_pressure": 10,
    "input_temperature": 30,
    "output_temperature": 23,
    "station": 12345,
    "user": "test",
  });

  static final mockGetShiftLastActionResponse =
      GetShiftLastActionResponse.fromJson({
        "id": 5,
        "date": "1402-11-23",
        "registered_datetime": "1403-09-18 11:03:33",
        "shift": "06",
        "input_pressure": 1,
        "output_pressure": 1,
        "input_temperature": 1,
        "output_temperature": 1,
        "station": 12346,
        "user": "admin",
      });

  static final mockGetShiftsDataListResponse =
      GetShiftsDataListResponse.fromJson({
        "count": 2,
        "next": null,
        "previous": null,
        "results": [
          {
            "id": 2,
            "date": "1403-04-20",
            "registered_datetime": "1403-09-10 17:43:49",
            "shift": "06",
            "input_pressure": 1,
            "output_pressure": 3,
            "input_temperature": 4,
            "output_temperature": 5,
            "station": 12345,
            "user": "admin",
          },
          {
            "id": 3,
            "date": "1403-11-09",
            "registered_datetime": "1403-09-11 10:35:56",
            "shift": "24",
            "input_pressure": 10,
            "output_pressure": 10,
            "input_temperature": 30,
            "output_temperature": 23,
            "station": 12345,
            "user": "test",
          },
        ],
      });

  static final mockCreateCorrectorRequest = CreateCorrectorRequest.fromJson({
    "date": "1403-01-05",
    "meter_amount": 50,
    "correction_amount": 50,
    "ran": 1,
  });

  static final mockCreateCorrectorResponse = CreateCorrectorResponse.fromJson({
    "date": "1403-01-05",
    "registered_datetime": null,
    "station_code": 12345,
    "meter_amount": 50,
    "correction_amount": 50,
    "ran": 1,
    "user": null,
  });

  static final mockUpdateCorrectorRequest = UpdateCorrectorRequest.fromJson({
    "date": "1403-09-13",
    "meter_amount": 15.0,
    "correction_amount": 25.0,
    "ran": 1,
  });

  static final mockUpdateCorrectorResponse = UpdateCorrectorResponse.fromJson({
    "id": 1,
    "date": "1403-09-13",
    "registered_datetime": "1403-09-11 10:40:50",
    "station_code": 12345,
    "meter_amount": 15,
    "correction_amount": 25,
    "ran": 1,
    "user": "test",
  });

  static final mockGetCorrectorDataListResponse =
      GetCorrectorDataListResponse.fromJson({
        "count": 1,
        "next": null,
        "previous": null,
        "results": [
          {
            "id": 1,
            "date": "1403-01-05",
            "registered_datetime": "1403-09-11 10:40:50",
            "station_code": 12345,
            "meter_amount": 50,
            "correction_amount": 50,
            "ran": 1,
            "user": "test",
          },
        ],
      });

  static final mockGetCorrectorDataResponse =
      GetCorrectorDataResponse.fromJson({
        "id": 1,
        "date": "1403-01-05",
        "registered_datetime": "1403-09-11 10:40:50",
        "station_code": 12345,
        "meter_amount": 50,
        "correction_amount": 50,
        "ran": 1,
        "user": "test",
      });

  static final mockGetMeterAndCorrectorFullReportResponse =
      GetMeterAndCorrectorFullReportResponse.fromJson({
        "count": 3,
        "next": null,
        "previous": null,
        "results": [
          {
            "station_code": 31141050000010,
            "user": "admin",
            "date": "1403-04-20",
            "registered_datetime": "1403-12-05 18:26:32.219415+0330",
            "rans": [
              {
                "meter_amount": 1,
                "corrector_amount": 1,
                "corrector_meter_amount": 1,
                "ran_sequence": 1,
                "ran": 311410500000101,
              },
              {
                "meter_amount": 1,
                "corrector_amount": 1,
                "corrector_meter_amount": 1,
                "ran_sequence": 2,
                "ran": 311410500000102,
              },
              {
                "meter_amount": 1,
                "corrector_amount": 1,
                "corrector_meter_amount": 1,
                "ran_sequence": 3,
                "ran": 311410500000103,
              },
            ],
          },
          {
            "station_code": 31141050000010,
            "user": "admin",
            "date": "1403-04-21",
            "registered_datetime": "1403-12-12 16:36:43.577097+0330",
            "rans": [
              {
                "meter_amount": 4,
                "corrector_amount": 4,
                "corrector_meter_amount": 4,
                "ran_sequence": 1,
                "ran": 311410500000101,
              },
              {
                "meter_amount": 4,
                "corrector_amount": 4,
                "corrector_meter_amount": 4,
                "ran_sequence": 2,
                "ran": 311410500000102,
              },
              {
                "meter_amount": 4,
                "corrector_amount": 4,
                "corrector_meter_amount": 4,
                "ran_sequence": 3,
                "ran": 311410500000103,
              },
            ],
          },
          {
            "station_code": 31141050000010,
            "user": "admin",
            "date": "1403-04-22",
            "registered_datetime": "1403-12-12 16:37:17.67951+0330",
            "rans": [
              {
                "meter_amount": 8,
                "corrector_amount": 8,
                "corrector_meter_amount": 8,
                "ran_sequence": 1,
                "ran": 311410500000101,
              },
              {
                "meter_amount": 8,
                "corrector_amount": 8,
                "corrector_meter_amount": 8,
                "ran_sequence": 2,
                "ran": 311410500000102,
              },
              {
                "meter_amount": 8,
                "corrector_amount": 8,
                "corrector_meter_amount": 8,
                "ran_sequence": 3,
                "ran": 311410500000103,
              },
            ],
          },
        ],
      });

  static final mockGetPressureAndTemperatureFullReportResponse =
      GetPressureAndTemperatureFullReportResponse.fromJson({
        "count": 3,
        "next": null,
        "previous": null,
        "results": [
          {
            "station_code": 31141050000010,
            "date": "1403-04-20",
            "shifts": [
              {
                "id": 1,
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:28:53.119717+0330",
                "user": "admin",
                "shift": "06",
              },
              {
                "id": 2,
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:29:10.423568+0330",
                "user": "admin",
                "shift": "12",
              },
              {
                "id": 3,
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:29:27.630016+0330",
                "user": "admin",
                "shift": "18",
              },
              {
                "id": 4,
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:31:31.54086+0330",
                "user": "admin",
                "shift": "24",
              },
            ],
          },
          {
            "station_code": 31141050000010,
            "date": "1403-04-21",
            "shifts": [
              {
                "id": 5,
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:39:57.23025+0330",
                "user": "admin",
                "shift": "06",
              },
              {
                "id": 6,
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:40:19.502577+0330",
                "user": "admin",
                "shift": "12",
              },
            ],
          },
          {
            "station_code": 31141050000010,
            "date": "1403-11-11",
            "shifts": [
              {
                "id": 7,
                "input_pressure": 100,
                "output_pressure": 150,
                "input_temperature": 3000,
                "output_temperature": 2300,
                "registered_datetime": "1403-12-08 12:08:50.738588+0330",
                "user": "test1",
                "shift": "12",
              },
            ],
          },
        ],
      });

  static final mockGetMonitoringFullReportResponse =
      GetMonitoringFullReportResponse.fromJson({
        "count": 3,
        "next": null,
        "previous": null,
        "results": [
          {
            "station_code": 31141050000010,
            "date": "1403-04-20",
            "shifts": [
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:28:53.119717+0330",
                "user": "admin",
                "shift": "06",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:29:10.423568+0330",
                "user": "admin",
                "shift": "12",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:29:27.630016+0330",
                "user": "admin",
                "shift": "18",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:31:31.54086+0330",
                "user": "admin",
                "shift": "24",
              },
            ],
            "consumption": null,
            "average_consumption": null,
          },
          {
            "station_code": 31141050000010,
            "date": "1403-04-21",
            "shifts": [
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:39:57.23025+0330",
                "user": "admin",
                "shift": "06",
              },
              {
                "input_pressure": 1,
                "output_pressure": 1,
                "input_temperature": 2,
                "output_temperature": 2,
                "registered_datetime": "1403-12-05 14:40:19.502577+0330",
                "user": "admin",
                "shift": "12",
              },
            ],
            "consumption": 9,
            "average_consumption": 9,
          },
          {
            "station_code": 31141050000010,
            "date": "1403-11-11",
            "shifts": [
              {
                "input_pressure": 100,
                "output_pressure": 150,
                "input_temperature": 3000,
                "output_temperature": 2300,
                "registered_datetime": "1403-12-08 12:08:50.738588+0330",
                "user": "test1",
                "shift": "12",
              },
            ],
            "consumption": null,
            "average_consumption": null,
          },
        ],
      });

  static final mockGetMeterChangeEventResponse =
      GetMeterChangeEventResponse.fromJson({
        "id": 1,
        "date": "1403-01-04",
        "station_code": 31101050000142,
        "ran_sequence": 1,
        "old_meter_amount": 102,
        "new_meter_amount": 100,
        "registered_datetime": "1403-12-04T17:31:47.503064+0330",
        "ran": 311010500001421,
        "user": null,
      });

  static final mockCreateMeterChangeEventRequest =
      CreateMeterChangeEventRequest.fromJson({
        "date": "1403-01-07",
        "ran": 311010500001421,
        "old_meter_amount": 50,
        "new_meter_amount": 100,
      });

  static final mockCreateMeterChangeEventResponse =
      CreateMeterChangeEventRequest.fromJson({
        "id": 3,
        "date": "1403-01-07",
        "station_code": 31101050000142,
        "ran_sequence": 1,
        "old_meter_amount": 50,
        "new_meter_amount": 100,
        "registered_datetime": "1403-12-04T17:51:42.794933+0330",
        "ran": 311010500001421,
        "user": "admin",
      });

  static final mockGetMeterChangeEventsList =
      GetMeterChangeEventsListResponse.fromJson({
        "count": 3,
        "next": null,
        "previous": null,
        "results": [
          {
            "id": 1,
            "date": "1403-01-04",
            "station_code": 31101050000142,
            "ran_sequence": 1,
            "old_meter_amount": 50,
            "new_meter_amount": 100,
            "registered_datetime": "1403-12-04T17:31:47.503064+0330",
            "ran": 311010500001421,
            "user": null,
          },
          {
            "id": 2,
            "date": "1403-01-05",
            "station_code": 31101050000142,
            "ran_sequence": 1,
            "old_meter_amount": 50,
            "new_meter_amount": 100,
            "registered_datetime": "1403-12-04T17:46:27.479274+0330",
            "ran": 311010500001421,
            "user": "admin",
          },
          {
            "id": 3,
            "date": "1403-01-07",
            "station_code": 31101050000142,
            "ran_sequence": 1,
            "old_meter_amount": 50,
            "new_meter_amount": 100,
            "registered_datetime": "1403-12-04T17:51:42.794933+0330",
            "ran": 311010500001421,
            "user": "admin",
          },
        ],
      });

  static final mockUpdateMeterChangeEventRequest =
      UpdateMeterChangeEventRequest.fromJson({
        "date": "1403-01-04",
        "ran": 311010500001421,
        "old_meter_amount": 102,
        "old_correction_amount": 103,
        "new_meter_amount": 100,
        "new_correction_amount": 120,
      });

  static final mockUpdateMeterChangeEventResponse =
      UpdateMeterChangeEventResponse.fromJson({
        "id": 1,
        "date": "1403-01-04",
        "station_code": 31101050000142,
        "ran_sequence": 1,
        "old_meter_amount": 102,
        "new_meter_amount": 100,
        "registered_datetime": "1403-12-04T17:31:47.503064+0330",
        "ran": 311010500001421,
        "user": null,
      });

  static final mockGetMeterChangeEventLastActionResponse =
      GetMeterChangeEventLastActionResponse.fromJson({
        "id": 3,
        "date": "1403-01-07",
        "station_code": 31101050000142,
        "ran_sequence": 1,
        "old_meter_amount": 50,
        "new_meter_amount": 100,
        "registered_datetime": "1403-12-04T17:51:42.794933+0330",
        "ran": 311010500001421,
        "user": "admin",
      });

  static final mockCreateCorrectorBulkRequest =
      PostCreateCorrectorBulkRequest.fromJson({
        "date": "1405-02-07",
        "rans": [
          {
            "ran": 311410500000101,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
          {
            "ran": 311410500000102,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
          {
            "ran": 311410500000103,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
        ],
      });

  static final mockCreateCorrectorBulkResponse =
      PostCreateCorrectorBulkResponse.fromJson({
        "station": 12346,
        "date": "1403-02-05",
        "rans": [
          {
            "meter_amount": 120,
            "correction_amount": 120,
            "ran_sequence": 1,
            "ran": 123461,
          },
          {
            "meter_amount": 7,
            "correction_amount": 7,
            "ran_sequence": 2,
            "ran": 123462,
          },
        ],
      });

  static final mockUpdateCorrectorBulkRequest =
      PutUpdateCorrectorBulkRequest.fromJson({
        "date": "1405-02-07",
        "rans": [
          {
            "ran": 311410500000101,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
          {
            "ran": 311410500000102,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
          {
            "ran": 311410500000103,
            "meter_amount": "1000",
            "corrector_amount": "1200",
            "corrector_meter_amount": "1000",
          },
        ],
      });

  static final mockUpdateCorrectorBulkResponse =
      PutUpdateCorrectorBulkResponse.fromJson({
        "station_code": 31141050000010,
        "date": "1405-02-07",
        "rans": [
          {
            "meter_amount": 1000,
            "corrector_amount": 1200,
            "corrector_meter_amount": 1000,
            "ran_sequence": 1,
            "ran": 311410500000101,
          },
          {
            "meter_amount": 1000,
            "corrector_amount": 1200,
            "corrector_meter_amount": 1000,
            "ran_sequence": 2,
            "ran": 311410500000102,
          },
          {
            "meter_amount": 1000,
            "corrector_amount": 1200,
            "corrector_meter_amount": 1000,
            "ran_sequence": 3,
            "ran": 311410500000103,
          },
        ],
        "user": null,
      });

  static final mockGetCorrectorDataBulkLastAction = [
    GetCorrectorDataBulkLastActionResponseListItem.fromJson({
      "date": "1403-01-01",
      "rans": [
        {
          "meter_amount": 1,
          "correction_amount": 1,
          "ran_sequence": 1,
          "ran": 123451,
        },
        {
          "meter_amount": 1,
          "correction_amount": 1,
          "ran_sequence": 2,
          "ran": 123452,
        },
        {
          "meter_amount": 1,
          "correction_amount": 1,
          "ran_sequence": 3,
          "ran": 123453,
        },
      ],
    }),
    GetCorrectorDataBulkLastActionResponseListItem.fromJson({
      "date": "1403-01-02",
      "rans": [
        {
          "meter_amount": 3,
          "correction_amount": 3,
          "ran_sequence": 1,
          "ran": 123451,
        },
        {
          "meter_amount": 3,
          "correction_amount": 3,
          "ran_sequence": 2,
          "ran": 123452,
        },
        {
          "meter_amount": 3,
          "correction_amount": 3,
          "ran_sequence": 3,
          "ran": 123453,
        },
      ],
    }),
  ];

  static final mockGetShiftDataBulkLastAction =
      GetShiftDataBulkLastActionResponse.fromJson({
        "id": 18,
        "date": "1403-11-11",
        "registered_datetime": " 1403-12-08 12:08:50",
        "shift": "12",
        "input_pressure": 100,
        "output_pressure": 150,
        "input_temperature": 3000,
        "output_temperature": 2300,
        "station": 31141050000010,
        "user": "test1",
      });

  static final mockGetStationDataList = GetStationDataListResponse.fromJson({
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
      {
        "code": "12345",
        "rans": [
          {"id": 1, "sequence_number": 1, "station": "12345"},
          {"id": 2, "sequence_number": 2, "station": "12345"},
          {"id": 3, "sequence_number": 3, "station": "12345"},
        ],
        "type": "CGS",
        "name": "رجایی",
        "district": "سمنان",
        "area": "گرمسار",
        "capacity": 1500,
      },
    ],
  });

  static final mockGetStationTypeDataListResponse =
      GetStationTypeDataListResponse.fromJson({
        "count": 1,
        "next": null,
        "previous": null,
        "results": [
          {"type_name": "CGS"},
        ],
      });

  static final mockGetStationDataResponse = GetStationDataResponse.fromJson({
    "code": "12345",
    "rans": [
      {"id": 1, "sequence_number": 1, "station": "12345"},
      {"id": 2, "sequence_number": 2, "station": "12345"},
      {"id": 3, "sequence_number": 3, "station": "12345"},
    ],
    "type": "CGS",
    "name": "رجایی",
    "district": "سمنان",
    "area": "گرمسار",
    "capacity": 1500,
  });

  static final mockGetStationTypeDataResponse =
      GetStationTypeDataResponse.fromJson({"type_name": "CGS"});

  static final mockPostCreateStationRequest =
      PostCreateStationRequest.fromJson({
        "code": 12347,
        "name": "بهشتی",
        "district": "سمنان",
        "area": "سمنان",
        "capacity": 1800,
        "type": 1,
      });

  static final mockPostCreateStationResponse =
      PostCreateStationResponse.fromJson({
        "code": "12347",
        "rans": [],
        "type_name": "CGS",
        "name": "بهشتی",
        "district": "سمنان",
        "area": "سمنان",
        "capacity": 1800,
        "type": 1,
      });
  static final mockPostCreateStationTypeRequest =
      PostCreateStationTypeRequest.fromJson({"type_name": "LPG"});

  static final mockPostCreateStationTypeResponse =
      PostCreateStationTypeResponse.fromJson({"type_name": "CNG"});

  static final mockPutUpdateStationDataRequest =
      PutUpdateStationDataRequest.fromJson({
        "code": 12347,
        "name": "بهشتی",
        "district": "سمنان",
        "area": "سمنان",
        "capacity": 2100,
        "type": 1,
      });

  static final mockPutUpdaateStationDataResponse =
      PutUpdateStationDataResponse.fromJson({
        "code": "12347",
        "rans": [],
        "type_name": "CGS",
        "name": "بهشتی",
        "district": "سمنان",
        "area": "سمنان",
        "capacity": 2100,
        "type": 1,
      });

  static final mockPutUpdateStationTypeDataRequest =
      PutUpdateStationTypeDataRequest.fromJson({"type_name": "GPG"});

  static final mockPutUpdateStationTypeDataResponse =
      PutUpdateStationTypeDataResponse.fromJson({"id": 2, "type_name": "GPG"});

  static final mockGetCorrectoChangeEventRequest =
      GetCorrectorChangeEventResponse.fromJson({
        "id": 1,
        "date": "1403-04-20",
        "station_code": 31141050000010,
        "ran_sequence": 2,
        "old_corrector_amount": 12,
        "new_corrector_amount": 17,
        "old_meter_amount": 25,
        "new_meter_amount": 40,
        "registered_datetime": "1403-12-05T11:14:02.437544+0330",
        "ran": 311410500000102,
        "user": "admin",
      });

  static final mockPostCreateCorrectorChangeEventRequest =
      PostCreateCorrectorChangeEventRequest.fromJson({
        "date": "1403-05-21",
        "old_corrector_amount": 12.0,
        "new_corrector_amount": 17.0,
        "old_meter_amount": 25.0,
        "new_meter_amount": 40.0,
        "ran": 311410500000102,
      });

  static final mockPostCreateCorrectorChangeEventResponse =
      PostCreateCorrectorChangeEventResponse.fromJson({
        "id": 2,
        "date": "1403-05-21",
        "station_code": 31141050000010,
        "ran_sequence": 2,
        "old_corrector_amount": 12,
        "new_corrector_amount": 17,
        "old_meter_amount": 25,
        "new_meter_amount": 40,
        "registered_datetime": "1403-12-05T11:17:00.912392+0330",
        "ran": 311410500000102,
        "user": "admin",
      });

  static final mockGetCorrectorChangeEventsList =
      GetCorrectorChangeEventListResponse.fromJson({
        "count": 2,
        "next": null,
        "previous": null,
        "results": [
          {
            "id": 1,
            "date": "1403-04-20",
            "station_code": 31141050000010,
            "ran_sequence": 2,
            "old_corrector_amount": 12,
            "new_corrector_amount": 17,
            "old_meter_amount": 25,
            "new_meter_amount": 40,
            "registered_datetime": "1403-12-05T11:14:02.437544+0330",
            "ran": 311410500000102,
            "user": "admin",
          },
          {
            "id": 2,
            "date": "1403-05-21",
            "station_code": 31141050000010,
            "ran_sequence": 2,
            "old_corrector_amount": 12,
            "new_corrector_amount": 17,
            "old_meter_amount": 25,
            "new_meter_amount": 40,
            "registered_datetime": "1403-12-05T11:17:00.912392+0330",
            "ran": 311410500000102,
            "user": "admin",
          },
        ],
      });

  static final mockPutUpdateCorrectorChangeEventRequest =
      PutUpdateCorrectorChangeEventRequest.fromJson({
        "id": 1,
        "date": "1403-04-20",
        "old_corrector_amount": 12,
        "new_corrector_amount": 17,
        "old_meter_amount": 26,
        "new_meter_amount": 41,
        "ran": 311410500000102,
        "user": "admin",
      });

  static final mockPutUpdateCorrectorChangeEventResponse =
      PutUpdateCorrectorChangeEventResponse.fromJson({
        "id": 1,
        "date": "1403-10-17",
        "station_code": "12345",
        "ran_sequence": 1,
        "old_meter_amount": 102,
        "old_correction_amount": 103,
        "new_meter_amount": 100,
        "new_correction_amount": 120,
        "ran": 1,
      });

  static final mockGetCorrectorChangeEventLastActionResponse =
      GetCorrectorChangeEventLastActionResponse.fromJson({
        "id": 2,
        "date": "1403-05-21",
        "station_code": 31141050000010,
        "ran_sequence": 2,
        "old_corrector_amount": 12,
        "new_corrector_amount": 17,
        "old_meter_amount": 25,
        "new_meter_amount": 40,
        "registered_datetime": "1403-12-05T11:17:00.912392+0330",
        "ran": 311410500000102,
        "user": "admin",
      });

  static final mockGetUsersCustomStationsGroupResponse =
      GetUsersCustomStationGroupResponse.fromJson({
        "count": 1,
        "next": null,
        "previous": null,
        "results": [
          {
            "id": 1,
            "title": "گروهبندی منطقه یکم",
            "user": "admin",
            "stations": [
              {"priority": 1, "station": 31141050000010},
              {"priority": 2, "station": 31121050000064},
            ],
          },
        ],
      });

  static final mockPostCreateNewStationGroupRequest =
      PostCreateNewStationGroupRequest.fromJson({
        "title": "گروهبندی منطقه",
        "user": "admin",
        "stations": [
          {"priority": 1, "station": 31141050000010},
          {"priority": 2, "station": 31121050000064},
        ],
      });

  static final mockPostCreateNewStationGroupResponse =
      PostCreateNewStationGroupResponse.fromJson({
        "title": "گروهبندی منطقه",
        "user": "admin",
        "stations": [
          {"priority": 1, "station": 31141050000010},
          {"priority": 2, "station": 31121050000064},
        ],
      });
}
