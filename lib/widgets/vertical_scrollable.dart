import 'package:flutter/material.dart';

class VerticalScrollable extends StatefulWidget {
  final Widget child;

  const VerticalScrollable({super.key, required this.child});

  @override
  State<VerticalScrollable> createState() => _VerticalScrollableState();
}

class _VerticalScrollableState extends State<VerticalScrollable> {
  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: controller,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.vertical,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
