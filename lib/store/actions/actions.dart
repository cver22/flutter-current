import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/auth_user/models/auth_state.dart';
import 'package:expenses/auth_user/models/user.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/entry/entry_model/entries_state.dart';
import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_model/logs_state.dart';
import 'package:expenses/login_register/login_register_model/login_or_register.dart';
import 'package:expenses/login_register/login_register_model/login_reg_state.dart';
import 'package:expenses/settings/settings_model/settings.dart';
import 'package:expenses/settings/settings_model/settings_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/validators.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:expenses/tags/tag_model/tag_state.dart';


part 'auth_actions.dart';

part 'login_reg_actions.dart';

part 'logs_actions.dart';

part 'entries_actions.dart';

part 'settings_actions.dart';

part 'single_entry_actions.dart';

part 'tag_actions.dart';

abstract class Action {
  AppState updateState(AppState appState);

}

//TODO update all actions to utilize private functions