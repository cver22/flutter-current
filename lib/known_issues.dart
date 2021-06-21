//TODO KNOWN ISSUES/ERRORS
//adding new category and subcategory to settings
//navigating to account screen

// TODO LONG TERM GOALS
// TODO setting option for auto insert decimal
//TODO reoccurring expenses

//TODO MAYBE GOALS
//TODO give each person an emoji Icon option


//TODO GENERAL
//TODO recover password
//TODO add customer journey account and setting setup screen to set the currency, create your categories, and add your name
// name to the same log, this will allow two logs to have the same categories even at the ID level regardless of their log
//TODO method to change the photo
//TODO how to handle auto scroll on the account screen and login screen
//TODO update all entries where a subcategory is deleted to use the "other" subcategory
//TODO confirm change password tool works as I have it commented out at the moment
//TODO add calculator
//TODO start splash screen earlier?
//TODO move tag list creators from UI (tag picker) to actions and state
//button on tags to visualize stats for that tag, spent, average, etc
//add blank option to new log categories
//modify setting categories to utilize 3 buttons, cancel, restore to factory, and save
//add anonymous sign in and create red banner asking the user to signup or risk losing their data
//TODO, give user option to change default payer on a log and from there the FAB button will chose that as default for EntrySetNewSelect, until then, it defaults to the user
//TODO tag recent use, modify UI
//TODO probably need to handle what happens when adding a new user to an existing log, how are the entries treated? Have option to add person to all previous entries
//TODO entries loaded from null should be given NO_CATEGORY AND NO_SUBCATEGORY defaults if the value is null
//TODO backup setting to cloud and retrieve
//TODO error checking for internet connection to refresh conversion rates and don't allow change of conversion rate if no exchange is present (maybe based on refresh date)
//TODO trace Renderings, why so much rendering duplication and re-rendering
//TODO fix paid spent averaging/rounding, use odd even days
//TODO add entriesFiltered and chartFiltered to entriesState and move filtering code from the UI so that its not handled on every rebuild of the UI
//add pull to refresh

//TODO VISUAL
//TODO appDialog needs an invisible icon on the trailing side if there is no trailing
//TODO selectable shadow color on logs
//TODO settings for month/day separator on the entries screen
//TODO make note that transfer funds do not show up in monthly totals
//TODO is there a better way to handle "Other" in entries tiles

//TODO CHART
//toggle stackedBar/line/donut
//add filter
//line chart by tag
//uses default currency by default but can select others (only one at a time)
//copy filter from entries if it is a valid chart filter




//TODO WARNINGS AND TOASTS to build
//add validation to min/max filter

//TODO PERFORMANCE
//make entry list tiles the same size and trail off too many tags
//can I run my data layer in an isolate?

//TODO GENERAL IMPORTANT *************************


//TODO START HERE
//formatters and converters need to accept conversion rates of 0 ?? this works i think
//build chart filter mechanism





//TODO ASK BORIS
// is having methods in the models bad practice, should they be extracted to the action - if it can be in an action, move it there - Answer - Yes

//HELPFUL COMMANDS
//flutter pub run build_runner build
//flutter pub run build_runner build --delete-conflicting-outputs
//flutter packages pub run build_runner build --delete-conflicting-import 'package:qr_flutter/qr_flutter.dart';
//flutter packages pub run build_runner build lib --delete-conflicting-outputs

//Conflicting outputs issue
// flutter clean
// flutter pub get
// flutter packages pub run build_runner build --delete-conflicting-import 'package:flutter/foundatioimport 'package:expenses/store/actions/single_entry_actions.import 'package:flutter/cupertino.dart';


