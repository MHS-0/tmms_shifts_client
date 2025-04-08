import 'package:flutter/material.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            ElevatedButton(child: Text("Click me!"), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
