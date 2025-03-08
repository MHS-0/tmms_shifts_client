import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageNotFoundRoute extends StatelessWidget {
  const PageNotFoundRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(child: Text("صفحه مورد نظر یافت نشد!")),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go("/");
                  },
                  child: Text("برکرد به صفحه اصلی"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
