import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';
import 'package:tmms_shifts_client/routes/monitoring_full_report_route.dart';

class PageNotFoundRoute extends StatelessWidget {
  static const routingName = "NotFound";

  const PageNotFoundRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SelectionArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(child: Text(localizations.pageNotFound)),
              Center(
                child: FilledButton(
                  onPressed: () {
                    context.goNamed(MonitoringFullReportRoute.routingName);
                  },
                  child: Text(localizations.returnToHomePage),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
