import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmms_shifts_client/data/backend_types.dart';
import 'package:tmms_shifts_client/main.dart';
import 'package:tmms_shifts_client/providers/preferences.dart';
import 'package:tmms_shifts_client/routes/login.dart';
import 'package:tmms_shifts_client/routes/monitoring_full_report_route.dart';

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
  });
}
