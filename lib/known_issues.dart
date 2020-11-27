//TODO deleting of logs does not make them go away
//TODO deleting of logs should also delete any of their entries, otherwise there is a loading error in entry ties
//TODO looping issue where saving a tag, rebuilds the log state in the back ground, what needs to happen is the log screen is not rebuilt because the selectedEntry is not empty
//TODO selected entry needs to be cleared when saving, but that caused a loop, need to utilize the isLoading state in entries state





// General TODO
//TODO re-ordrerable list for categories
//TODO change entry log so that all entries are in a single file for a single log, will reduce firestore costs
// to reduce costs, look at storing the entry sets by month or year to allow for enough data per document without chance of hitting the limit
//TODO method to delete tags and connections to categories/entries i nthe log editor, also be able to edit the tags in that location
//TODO methods to do combined updating of states such as the entry and log state at the same time for some reason?