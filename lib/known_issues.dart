      //TODO KNOWN ISSUES
//TODO selected entry needs to be cleared when saving, but that caused a loop, need to utilize the isLoading state in entries state
//TODO going back from entry does not clear the logTags from the singleEntryState logTagList




      //TODO General
//TODO re-ordrerable list for categories - this may be solveable by creating category/subcategory state for manipulation and then eventually savings
//TODO organize and filter entries in various ways
//TODO how to put an empty map in a JSON so the array doesn't initiate empty
      //TODO record of total log expenditure by month
      //TODO implement currency exchange rates
      //TODO allow user to change password, recover password
      //TODO setting option for auto insert decimal
      //TODO reoccurring expenses
      //TODO don't show the currency on a log in the list if it is the default currency
      //TODO find an api to get the currency exchange rate information
      //TODO Settings are not being retrieved? JSON error?
      //TODO do I want to move to null safety?
      //TODO add_edit_entries_screen, keyboard data stream should be cleared when entering values that are not accepted
      //TODO remove all data handling from the models?
      //TODO how to track total spends
      //TODO spent - distribute to others methods
      //TODO add customer journey account and setting setup screen to set the currency, create your categories, and add your name
      // name to the same log, this will allow two logs to have the same categories even at the ID level regardless of their log
      //TODO change all data models to Maybe
      //TODO give each person an emoji Icon option
      //TODO entries safety check before loading if their category has been deleted, show no category
      //TODO remove subcategory class and utilize only the category class, parentCategory either null or valid
      //TODO can totals for the logs be handled in a more efficient way?



      //TODO important issues *************************
      //TODO deal with focusNode when i can add members and also modify paid amounts


    //TODO START HERE
//need to rethink how and when I calculate the totals, maybe there should be an action triggered everytime the logscreen builds
      //the action checks to see if the values are the same, if they are, it returns the current log state which due to being identical, would not cause a rebuild
      //i can test this with a dummy action that just returns the same logState, if it rebuilds its and issue, if it doesn't this should work



      //TODO ASK BORIS
      //should I keep track of total amounts in the database or use live values calculated when pulling the data each time
      //is having methods in the models bad practice, should they be extracted to the action - if it can be in an action, move it there



      //flutter pub run build_runner build
      //flutter packages pub run build_runner build --delete-conflicting-import 'package:qr_flutter/qr_flutter.dart';
