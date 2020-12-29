      //TODO KNOWN ISSUES
//TODO deleting of logs should also delete any of their entries, otherwise there is a loading error in entry ties
//TODO selected entry needs to be cleared when saving, but that caused a loop, need to utilize the isLoading state in entries state
//TODO going back from entry does not clear the logTags from the singleEntryState logTagList




      //TODO General
//TODO re-ordrerable list for categories - this may be solveable by creating category/subcategory state for manipulation and then eventually savings
//TODO edit tags
//TODO methods to do combined updating of states such as the entry and log state at the same time for some reason?
//TODO organize and filter entries in various ways
//TODO deleting a log deletes all of its entries and tags in the app and firestore
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





    //TODO START HERE
// change entry/log members to utilize the Money package
      // will need to import log currency  for saving and retrieving the values from firestore, other option is to save the log currency on all entries so it can be used there
      //one other option could be to inject it when retrieving the entity before its sent to the model



      //TODO ASK BORIS
      //should I keep track of total amounts in the database or use live values calculated when pulling the data each time