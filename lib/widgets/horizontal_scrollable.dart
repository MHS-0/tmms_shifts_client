import 'package:flutter/material.dart';

class HorizontalScrollable extends StatefulWidget {
  final Widget child;

  const HorizontalScrollable({super.key, required this.child});

  @override
  State<HorizontalScrollable> createState() => _HorizontalScrollableState();
}

class _HorizontalScrollableState extends State<HorizontalScrollable> {
  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: controller,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
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
