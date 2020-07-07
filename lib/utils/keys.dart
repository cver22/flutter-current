import 'package:flutter/widgets.dart';

class ExpenseKeys {
  // Main
  static final main = const Key('__main__');

  // Home Screens
  static final homeScreen = const Key('__homeScreen__');
  static final appScreen = const Key('__appScreen__');
  static final splashScreen = const Key('__splashScreen__');

  //Account Screen
  static final accountScreen = const Key('__accountScreen__');


  // Tabs
  /*static final tabSelector = const Key('__tabSelector__');
  static final logsTab = const Key('__logsTab__');
  static final entriesTab = const Key('__entriesTab__');*/

  // App Drawer
  static final appDrawer = const Key('__appDrawer__');

  // Common Widgets
  static final emptyContent = const Key('__emptyContent__');

  // Login Screens
  static final loginScreen = const Key('__loginScreen__');
  static final loginForm = const Key('__loginForm__');
  static final loginButton = const Key('__loginButton__');
  static final googleLoginButton = const Key('__googleLoginButton');
  static final createAccountButton = const Key('createAccountButton');

  // Entries Screens
  static final entriesScreen = const Key('__entriesScreen__');
  static final addEditEntriesScreen = const Key('__addEditEntriesScreen__');


  // Logs Page
  static final logsScreen = const Key('__logsScreen__');
  static final addEditLogScreen = const Key('__addEditLogScreen__');
}
