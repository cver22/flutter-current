import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/env.dart';
import 'package:expenses/login_register/login_register_model/login_or_register.dart';
import 'package:expenses/login_register/login_register_model/login_reg_state.dart';
import 'package:expenses/login_register/login_register_ui/create_account_button.dart';
import 'package:expenses/login_register/login_register_ui/google_login_button.dart';
import 'package:expenses/login_register/login_register_ui/login_register_button.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expenses/utils/expense_routes.dart';

class LoginRegisterForm extends StatefulWidget {
  @override
  _LoginRegisterFormState createState() => _LoginRegisterFormState();
}

class _LoginRegisterFormState extends State<LoginRegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get isPopulated => _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLogin(LoginRegState state) {
    return state.loginOrRegister == LoginOrRegister.login;
  }

  bool isLoginButtonEnabled(LoginRegState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
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
          print('Rendering Login Register Form');
          print('Login status: ${state.loginStatus}');
          print('LoginOrRegister: ${state.loginOrRegister}');

          if (Env.store.state.authState.user.isSome) {
            Future.delayed(Duration.zero, () {
              Get.toNamed(ExpenseRoutes.home);
            });
          }

          return Stack(
            children: <Widget>[
              Padding(
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
                            LoginRegisterButton(
                              onPressed: isLoginButtonEnabled(state) ? () => _onFormSubmitted(state, context) : null,
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
              ),
              ModalLoadingIndicator(
                  loadingMessage: state.loginOrRegister == LoginOrRegister.login ? 'Logging In' : 'Registering',
                  activate: state.isSubmitting)
            ],
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
    Env.userFetcher.signInOrRegisterWithCredentials(
        email: _emailController.text.toString().trim(),
        password: _passwordController.text.toString(),
        loginRegState: loginState);
  }
}
