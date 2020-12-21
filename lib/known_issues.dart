      //TODO KNOWN ISSUES
//TODO deleting of logs should also delete any of their entries, otherwise there is a loading error in entry ties
//TODO selected entry needs to be cleared when saving, but that caused a loop, need to utilize the isLoading state in entries state
//TODO going back from entry does not clear the logTags from the singleEntryState logTagList




      //TODO General
//TODO re-ordrerable list for categories - this may be solveable by creating category/subcategory state for manipulation and then eventually savings
//TODO edit tags
//TODO methods to do combined updating of states such as the entry and log state at the same time for some reason?
//TODO organize and filter entries in various ways
//TODO deleting a log deletes all of its entries and tags
//TODO how to put an empty map in a JSON so the array doesn't initiate empty
      //TODO record of total log expenditure by month
      //TODO implement currency exchange rates
      //TODO entry can't save if the member paid/spent total doesn't equal the entry total, paid should default to the entry value
      //TODO allow user to change password, change name, recover password
      //TODO setting option for auto insert decimal
      //TODO reoccurring expenses





    //TODO START HERE
//member entry tiles, need to be able to edit the amount, will need an action for that as it needs to adjust all other values



      //TODO ASK BORIS
      //should I keep track of total amounts in the database or use live values calculated when pulling the data each time