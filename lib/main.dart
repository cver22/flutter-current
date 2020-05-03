import 'package:expenses/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:expenses/blocs/logs_bloc/logs_bloc.dart';
import 'package:expenses/screens/home_screen.dart';
import 'package:expenses/screens/login/login_screen.dart';
import 'package:expenses/screens/splash_screen.dart';
import 'package:expenses/services/logs_repository.dart';
import 'package:expenses/services/user_repository.dart';
import 'package:expenses/utils/simple_bloc_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/logs_bloc/bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // allows code before runApp
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final FirebaseUserRepository userRepository = FirebaseUserRepository();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) =>
              AuthenticationBloc(userRepository: userRepository)
                ..add(AppStarted()),
        ),
      ],
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final FirebaseUserRepository _userRepository;

  const App({Key key, @required FirebaseUserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        // ignore: missing_return
        builder: (context, state) {
          if (state is Uninitialized) {
            return SplashScreen();
          }
          if (state is Unauthenticated) {
            return LoginScreen(userRepository: _userRepository);
          }
          if (state is Authenticated) {
            final FirebaseLogsRepository _logsRepository = FirebaseLogsRepository(user: state.user);
            return BlocProvider<LogsBloc>(
                create: (context) => LogsBloc(logsRepository: _logsRepository)..add(LoadLogs()),
          child: HomeScreen(),);
          }
        },
      ),
    );
  }
}
