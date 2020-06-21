import 'package:expenses/env.dart';
import 'package:expenses/models/login/login_or_register.dart';
import 'package:expenses/models/login/login__reg_status.dart';
import 'package:expenses/screens/login/google_login_button.dart';
import 'package:expenses/screens/login/login_button.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:expenses/models/login/login_reg_state.dart';
import 'package:expenses/screens/login/create_account_button.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLogin(LoginRegState state) {
    return state.loginOrRegister == LoginOrRegister.login;
  }

  bool isLoginButtonEnabled(LoginRegState state) {
    return state.isFormValid &&
        isPopulated &&
        state.loginStatus != LoginStatus.submitting;
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return ConnectState<LoginRegState>(
        where: notIdentical,
        map: (state) => state.loginRegState,
        builder: (state) {
          print('Login status: ${state.loginStatus}');
          print('LoginOrRegister: ${state.loginOrRegister}');

          /*if (loginState.loginStatus == LoginStatus.failure) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Login Failure'),
                        Icon(Icons.error)
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
            } else if (loginState.loginStatus == LoginStatus.submitting) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Logging in...'),
                        CircularProgressIndicator(),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
            }*/

          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Image.asset('assets/flutter_logo.png', height: 200),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autovalidate: true,
                    autocorrect: false,
                    //TODO need email validation
                    validator: (_) {
                      return !state.isEmailValid ? 'Invalid Email' : null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    autovalidate: true,
                    autocorrect: false,
                    //TODO delay password validation
                    validator: (_) {
                      return !state.isPasswordValid ? 'Minimum 10 characters' : null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: <Widget>[
                        LoginButton(
                          onPressed: isLoginButtonEnabled(state)
                              ? () => _onFormSubmitted(state, context)
                              : null,
                          name: isLogin(state) ? 'Login' : 'Register',
                        ),
                        GoogleLoginButton(
                          enabled: isLogin(state),
                          loginRegState: state,
                        ),
                        CreateAccountButton(loginState: state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _onEmailChanged() {
    Env.store.dispatch(EmailValidation(_emailController.text));
  }

  void _onPasswordChanged() {
    Env.store.dispatch(PasswordValidation(_passwordController.text));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFormSubmitted(LoginRegState loginState, BuildContext context) {
    if (isLogin(loginState)) {
      Env.userFetcher.signInWithCredentials(
          email: _emailController.text.toString().trim(),
          password: _passwordController.text.toString(),
          loginRegState: loginState);
    } else {
      Env.userFetcher.registerWithCredentials(
          email: _emailController.text.toString().trim(),
          password: _passwordController.text.toString(),
          loginRegState: loginState);
    }
  }
}
