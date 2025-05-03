import 'package:flutter/widgets.dart';
import 'package:tmms_shifts_client/consts.dart';
import 'package:tmms_shifts_client/widgets/data_fetch_error.dart';

/// A simple wrapper for FutureBuilder, where a fullscreen [DataFetchError]
/// will be shown on future error, the [centeredCircularProgressIndicator] will be shown
/// while it's incomplete, and otherwise, the specified widget in the builder will be shown.
class DataFetchFutureBuilder<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget Function(BuildContext context, T data) builder;

  /// A simple wrapper for FutureBuilder, where a fullscreen [DataFetchError]
  /// will be shown on future error, the [centeredCircularProgressIndicator] will be shown
  /// while it's incomplete, and otherwise, the specified widget in the builder will be shown.
  const DataFetchFutureBuilder({super.key, this.future, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DataFetchError(content: snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return centeredCircularProgressIndicator;
        } else if (snapshot.hasData && snapshot.data != null) {
          // ignore: null_check_on_nullable_type_parameter
          return builder(context, snapshot.data!);
        } else {
          return emptySizedBox;
        }
      },
    );
  }
}
