

import 'package:expenses/models/app_state.dart';
import 'package:expenses/models/app_tab.dart';

part 'tab_actions.dart';

abstract class Action {
  AppState updateState(AppState appState);
}