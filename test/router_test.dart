import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/main.dart';
import 'package:tmms_shifts_client/providers/date_picker_provider.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/providers/selected_stations_provider.dart';
import 'package:tmms_shifts_client/routes/login.dart';
import 'package:tmms_shifts_client/routes/monitoring_full_report_route.dart';
import 'package:tmms_shifts_client/routes/pressure_and_temp_reports_route.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Router Tests", () {
    testWidgets("Show login if not logged in", (tester) async {
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
    });

    testWidgets("Show MonitoringFullReportRoute if logged in", (tester) async {
      SharedPreferences.setMockInitialValues({
        activeUserKey: jsonEncode(MockData.mockActiveUser),
      });
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
      expect(find.byType(MonitoringFullReportRoute), findsOne);
    });

    testWidgets("2Show MonitoringFullReportRoute if logged in", (tester) async {
      final Size testSize = Size(1280, 720);
      tester.view.physicalSize = testSize;
      SharedPreferences.setMockInitialValues({
        activeUserKey: jsonEncode(MockData.mockActiveUser),
      });
      await Preferences.instance().load();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: Preferences.instance()),
            ChangeNotifierProvider(create: (_) => DatePickerProvider()),
            ChangeNotifierProvider(create: (_) => SelectedStationsProvider()),
          ],
          child: MaterialApp(
            home: const PressureAndTempReportsRoute(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PressureAndTempReportsRoute), findsOne);
    });
  });
}
