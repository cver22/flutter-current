      //TODO KNOWN ISSUES
//TODO selected entry needs to be cleared when saving, but that caused a loop, need to utilize the isLoading state in entries state ***still an issue***
//TODO going back from entry does not clear the logTags from the singleEntryState logTagList

      //TODO Log Term Goals
      // TODO setting option for auto insert decimal
      //TODO reoccurring expenses


      //TODO General
//TODO re-ordrerable list for categories - this may be solveable by creating category/subcategory state for manipulation and then eventually savings
//TODO organize and filter entries in various ways
      //TODO implement currency exchange rates
      //TODO allow user to change password, recover password
      //TODO don't show the currency on a log in the list if it is the default currency
      //TODO find an api to get the currency exchange rate information
      //TODO Settings are not being retrieved? JSON error?
      //TODO do I want to move to null safety?
      //TODO add_edit_entries_screen, keyboard data stream should be cleared when entering values that are not accepted
      //TODO remove all data handling from the models?
      //TODO spent - distribute to others methods
      //TODO add customer journey account and setting setup screen to set the currency, create your categories, and add your name
      // name to the same log, this will allow two logs to have the same categories even at the ID level regardless of their log
      //TODO change all data models to Maybe
      //TODO give each person an emoji Icon option
      //TODO log order for log screen
      //TODO clicking in a focusNode value for a member should tick its
      //TODO ask the user to add a category or subcategory if the is none on the dialog/add error message is none load?




      //TODO important issues *************************
      //TODO deal with focusNode when i can add members and also modify paid amounts


    //TODO START HERE
      //build list views for the log and settings categories and subcategories
//build filter dialog
      //build function to return filtered list back to the widget


      //TODO ASK BORIS
      // is having methods in the models bad practice, should they be extracted to the action - if it can be in an action, move it there - Answer - Yes



      //flutter pub run build_runner build
      //flutter packages pub run build_runner build --delete-conflicting-import 'package:qr_flutter/qr_flutter.dart';
