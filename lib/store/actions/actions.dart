import 'package:expenses/env.dart';
import 'package:expenses/models/app_state.dart';
import 'package:expenses/models/auth/auth_state.dart';
import 'package:expenses/models/entry/entries_state.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/models/log/logs_state.dart';
import 'package:expenses/models/login_register/login_reg_state.dart';
import 'package:expenses/models/settings/settings.dart';
import 'package:expenses/models/settings/settings_state.dart';
import 'package:expenses/models/user.dart';
import 'package:expenses/services/fetchers/settings_fetcher.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/validators.dart';
import 'package:meta/meta.dart';

part 'auth_actions.dart';

part 'login_reg_actions.dart';

part 'logs_actions.dart';

part 'entries_actions.dart';

part 'settings_actions.dart';

abstract class Action {
  AppState updateState(AppState appState);

}

//TODO update all actions to utilize private functions