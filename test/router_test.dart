import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:logging/logging.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/helpers.dart';
import 'package:tmms_shifts_client/main.dart';
import 'package:tmms_shifts_client/network_interface.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/routes/login.dart';
import 'package:tmms_shifts_client/routes/monitoring_full_report_route.dart';
import 'package:tmms_shifts_client/routes/pressure_and_temp_reports_route.dart';
import 'package:tmms_shifts_client/widgets/data_fetch_error.dart';

import 'network_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print("${record.level.name} ${record.time}: ${record.message}");
  });

  group("Router Tests (with active user set)", () {
    const customDelay = Duration(milliseconds: 0);
    final dioAdapter = DioAdapter(dio: globalDio);

    setUpAll(() async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({
        activeUserKey: jsonEncode(MockData.mockActiveUser),
      });
      await Preferences.instance().load();
      globalNetworkInterface.dio;
      NetworkInterface.updateUsedToken();

      final respJsonMonitoring =
          MockData.mockGetMonitoringFullReportResponse.toJson();
      final respJsonProfile = MockData.mockGetProfileResponse.toJson();
      final respJsonStationGroups =
          MockData.mockGetUsersCustomStationsGroupResponse.toJson();
      final respJsonPressureAndTempFullReport =
          MockData.mockGetPressureAndTemperatureFullReportResponse.toJson();

      dioAdapter.onGet(
        "/reports/monitoring/full_report",
        (server) {
          server.reply(200, respJsonMonitoring, delay: customDelay);
        },
        queryParameters:
            ToFromDateStationsQuery(
              fromDate: Helpers.jalaliToDashDate(Jalali.now().addDays(-1)),
              toDate: Helpers.jalaliToDashDate(Jalali.now()),
            ).toJson(),
        headers: NetworkInterface.filledHeaderMap,
      );

      dioAdapter.onGet("/user/profile/", (server) {
        server.reply(200, respJsonProfile, delay: customDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      dioAdapter.onGet("/reports/station_groups/", (server) {
        server.reply(200, respJsonStationGroups, delay: customDelay);
      }, headers: NetworkInterface.filledHeaderMap);

      dioAdapter.onGet(
        "/reports/pressure_and_temperature/full_report",
        (server) {
          server.reply(
            200,
            respJsonPressureAndTempFullReport,
            delay: customDelay,
          );
        },
        queryParameters:
            ToFromDateStationsQuery(
              fromDate: Helpers.jalaliToDashDate(Jalali.now().addDays(-1)),
              toDate: Helpers.jalaliToDashDate(Jalali.now()),
            ).toJson(),
        headers: NetworkInterface.filledHeaderMap,
      );
    });

    testWidgets("Show MonitoringFullReportRoute if logged in", (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: Preferences.instance()),
          ],
          child: const App(),
        ),
      );
      // We use two pump and settles here because of the async related tasks inside
      // the redirect functionality of GoRouter that we use.
      // Otherwise, the tasks wouldn't complete (because of the fake async zone of the test)
      // and it ends up failing.
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(find.byType(MonitoringFullReportRoute), findsOne);
      expect(find.byType(DataFetchError), findsNothing);
    });

    testWidgets("Pressure and Temp basic test", (tester) async {
      final Size testSize = Size(1920, 1080);
      tester.view.physicalSize = testSize;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: Preferences.instance()),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.thermostat_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(PressureAndTempReportsRoute), findsOne);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(find.byType(DataFetchError), findsNothing);
      expect(find.byWidget(centeredCircularProgressIndicator), findsNothing);
    });
  });

  group("Router Tests (with active user unset)", () {
    testWidgets("Show login if not logged in", (tester) async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({});
      await Preferences.instance().load();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: Preferences.instance()),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginRoute), findsOne);
      expect(find.byType(DataFetchError), findsNothing);
    });
  });
}
