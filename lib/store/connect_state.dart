import 'package:expenses/env.dart';
import 'package:expenses/models/app_state.dart';
import 'package:flutter/widgets.dart';

class ConnectState<T> extends StatelessWidget {
  final T Function(AppState appState) map;
  final bool Function(T prev, T next) where;
  final Widget Function(T state) builder;

  const ConnectState({
    Key key,
    @required this.map,
    @required this.where,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: Env.store.state$
          .map(map)
          .distinct((T prev, T next) => !where(prev, next)),
      builder: (context, snapshot){
        if(snapshot.data == null){
          return Container();
        }
        return builder(snapshot.data);
      }
    );
  }
}
