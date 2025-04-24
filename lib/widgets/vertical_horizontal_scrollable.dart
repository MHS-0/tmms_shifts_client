import 'package:flutter/material.dart';
import 'package:tmms_shifts_client/widgets/horizontal_scrollable.dart';
import 'package:tmms_shifts_client/widgets/vertical_scrollable.dart';

class BothScrollable extends StatelessWidget {
  final Widget child;

  const BothScrollable({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return VerticalScrollable(child: HorizontalScrollable(child: child));
  }
}
