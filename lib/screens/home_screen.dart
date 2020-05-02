import 'package:expenses/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:expenses/blocs/login_bloc/bloc.dart';
import 'package:expenses/blocs/logs_bloc/bloc.dart';
import 'package:expenses/models/user/user.dart';
import 'package:expenses/screens/drawer/app_drawer.dart';
import 'package:expenses/screens/logs/logs_page.dart';
import 'package:expenses/services/logs_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseLogsRepository _logsRepository = FirebaseLogsRepository(user: user);
    return BlocProvider<LogsBloc>(
      create: (context) => LogsBloc(logsRepository: _logsRepository)..add(LoadLogs()),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: AppDrawer(),
          appBar: AppBar(
            actions: <Widget>[],
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.account_balance_wallet)),
                Tab(icon: Icon(Icons.assignment)),
                Tab(icon: Icon(Icons.assessment)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              LogsPage(),
              /*Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text('Welcome $name'),
                  ),
                ],
              ),*/
              Icon(Icons.assignment),
              Icon(Icons.assessment),
            ],
          ),



        ),
      ),
    );
  }
}
