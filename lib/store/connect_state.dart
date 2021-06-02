import 'package:flutter/widgets.dart';

import '../app/models/app_state.dart';
import '../utils/bool_extensions.dart';
import '../env.dart';

class ConnectState<T> extends StatelessWidget {
  final T Function(AppState appState) map;
  final bool Function(T prev, T next)? where;
  final Widget Function(T state) builder;
  final

  const ConnectState({
    Key? key,
    required this.map,
    this.where,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: Env.store.state$
            .map(map)
            .distinct((T prev, T next) => this.where?.call(prev, next).negate() ?? identical(prev, next)),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          }
          return builder(snapshot.data!);
        });
  }
}
