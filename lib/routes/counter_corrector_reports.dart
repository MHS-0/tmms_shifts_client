import 'package:flutter/material.dart';
import 'package:tmms_shifts_client/widgets/drawer.dart';

class CounterCorrectorReportsRoute extends StatefulWidget {
  final int? report;

  const CounterCorrectorReportsRoute({super.key, this.report});

  @override
  State<CounterCorrectorReportsRoute> createState() =>
      _CounterCorrectorReportsRouteState();
}

class _CounterCorrectorReportsRouteState
    extends State<CounterCorrectorReportsRoute> {
  Future<int> getReports() async {
    await Future.delayed(Duration(seconds: 2));
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: null,
      future: getReports(),
      builder: (context, snapshot) {
        final Widget widget;
        if (snapshot.hasData) {
          widget = Center(child: Text("stuff"));
        } else {
          widget = Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("گزارش کنتور و تصحیح کننده"),
            centerTitle: true,
          ),
          drawer: MyDrawer(),
          body: widget,
        );
      },
    );
  }
}
