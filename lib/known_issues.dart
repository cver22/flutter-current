//TODO KNOWN ISSUES

// TODO LONG TERM GOALS
// TODO setting option for auto insert decimal
//TODO reoccurring expenses

//TODO MAYBE GOALS
//TODO give each person an emoji Icon option
//TODO do I want to move to null safety?


//TODO GENERAL
//TODO recover password
//TODO don't show the currency on a log in the list if it is the default currency
//TODO find an api to get the currency exchange rate information
//TODO Settings are not being retrieved? JSON error?
//TODO add customer journey account and setting setup screen to set the currency, create your categories, and add your name
// name to the same log, this will allow two logs to have the same categories even at the ID level regardless of their log
//TODO method to change the photo
//TODO how to handle auto scroll on the account screen and login screen
//TODO update all entries where a subcategory is deleted to use the "other" subcategory
//TODO confirm change password tool works as I have it commented out at the moment
//TODO track subcategory tag frequency
//TODO log order needs to be an individual thing, as multiple users with different logs will oder them differently
//TODO add calculator
//TODO start splash screen earlier?
//TODO move tag list creators from UI (tag picker) to actions and state
//button on tags to visualize stats for that tag, spent, average, etc
//add blank option to new log


//TODO VISUAL
//TODO appDialog needs an invisible icon on the trailing side if there is no trailing
//TODO filter dialog and tag filter should be full size
//TODO selectable shadow color on logs
//TODO settings for month/day separator on the entries screen



//TODO WARNINGS AND TOASTS to build
//TODO filter, min must be less than max



//TODO GENERAL IMPORTANT *************************

//TODO START HERE
//filter dialog and tag dialog may need to be custom built dialogs as they do not compress well, maybe try an alert dialog
//saving a tag should clear the search





//TODO ASK BORIS
// is having methods in the models bad practice, should they be extracted to the action - if it can be in an action, move it there - Answer - Yes

//HELPFUL COMMANDS
//flutter pub run build_runner build
//flutter packages pub run build_runner build --delete-conflicting-import 'package:qr_flutter/qr_flutter.dart';

//Conflicting outputs issue
// flutter clean
// flutter pub get
// flutter packages pub run build_runner build --delete-conflicting-outputs