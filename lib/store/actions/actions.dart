import 'package:expenses/models/app_state.dart';
import 'package:expenses/models/auth/auth_state.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/models/log/logs_state.dart';
import 'package:expenses/models/login_register/login_reg_state.dart';
import 'package:expenses/models/user.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/validators.dart';



part 'auth_actions.dart';
part 'login_reg_actions.dart';
part 'logs_actions.dart';

abstract class Action {
  AppState updateState(AppState appState);
}
