import 'package:expenses/models/app_state.dart';
import 'package:expenses/models/auth/auth_state.dart';
import 'package:expenses/models/auth/auth_status.dart';
import 'package:expenses/models/login/login_reg_state.dart';
import 'file:///D:/version-control/flutter/expenses/lib/models/user.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/validators.dart';



part 'auth_actions.dart';
part 'login_reg_actions.dart';

abstract class Action {
  AppState updateState(AppState appState);
}