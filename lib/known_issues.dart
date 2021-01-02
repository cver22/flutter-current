      //TODO KNOWN ISSUES
//TODO deleting of logs should also delete any of their entries, otherwise there is a loading error in entry ties
//TODO selected entry needs to be cleared when saving, but that caused a loop, need to utilize the isLoading state in entries state
//TODO going back from entry does not clear the logTags from the singleEntryState logTagList




      //TODO General
//TODO re-ordrerable list for categories - this may be solveable by creating category/subcategory state for manipulation and then eventually savings
//TODO edit tags
//TODO organize and filter entries in various ways
//TODO how to put an empty map in a JSON so the array doesn't initiate empty
      //TODO record of total log expenditure by month
      //TODO implement currency exchange rates
      //TODO entry can't save if the member paid/spent total doesn't equal the entry total, paid should default to the entry value
      //TODO allow user to change password, change name, recover password
      //TODO setting option for auto insert decimal
      //TODO reoccurring expenses
      //TODO don't show the currency on a log in the list if it is the default currency
      //TODO find an api to get the currency exchange rate information
      //TODO Settings are not being retrieved
      //TODO deal with focusNode when i can add members
      //TODO do I want to move to null safety?
      //TODO add_edit_entries_screen, keyboard data stream should be cleared when entering values that are not accepted
      //TODO remove all data handling from the models
      //TODO how to track total spends





    //TODO START HERE
//add get to camera for the log screen



      //TODO ASK BORIS
      //should I keep track of total amounts in the database or use live values calculated when pulling the data each time
      //is having methods in the models bad practice, should they be extracted to the action