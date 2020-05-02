import 'package:expenses/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:expenses/screens/home_screen.dart';
import 'package:expenses/screens/login/login_screen.dart';
import 'package:expenses/screens/splash_screen.dart';
import 'package:expenses/services/user_repository.dart';
import 'package:expenses/utils/simple_bloc_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // allows code before runApp
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final FirebaseUserRepository userRepository = FirebaseUserRepository();
  runApp(BlocProvider<AuthenticationBloc>(
    create: (context) =>
        AuthenticationBloc(userRepository: userRepository)..add(AppStarted()),
    child: App(userRepository: userRepository),
  ));
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
        builder: (context, state) {
          if (state is Uninitialized) {
            return SplashScreen();
          }
          if (state is Unauthenticated) {
            return LoginScreen(userRepository: _userRepository);
          }
          if (state is Authenticated) {
            return HomeScreen(name: state.displayName);
          }
        },
      ),
    );
  }

}
