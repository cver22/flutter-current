import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/app/common_widgets/error_widget.dart';
import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/entry/entry_model/entries_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/entry/entry_screen/entry_list_tile.dart';
import 'package:expenses/env.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EntriesScreen extends StatelessWidget {
  EntriesScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MyEntry> _entries = [];
    Env.entriesFetcher.loadEntries();
    return Scaffold(
      floatingActionButton: FloatingActionButton(

        //TODO abstract this away from the ui
        //TODO deactivate add entries button if there is no default log
        //TODO pass default log or retrieve from state
        onPressed: () {
          String defaultLogId = Env.store.state.settingsState.settings.value.defaultLogId;
          if (defaultLogId != null && Env.store.state.logsState.logs.containsKey(defaultLogId)) {
            //sets logId for selected entry to defaultLogId for new entry when navigating from FAB
            Env.store.dispatch(SetNewSelectedEntry(logId: defaultLogId));
            Get.toNamed(ExpenseRoutes.addEditEntries);

          } else {
            //TODO user/error message, set a default log
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Please set a default log."),
            ));
          }
        },

        child: Icon(Icons.add),
      ),
      body: ConnectState<EntriesState>(
        where: notIdentical,
        map: (state) => state.entriesState,
        builder: (entriesState) {
          print('Rendering entries screen');
          print('Entries State: $entriesState');

          if (entriesState.isLoading == true) {
            return ModalLoadingIndicator(loadingMessage: 'Loading your entries...');
          } else if (entriesState.isLoading == false && entriesState.entries.isNotEmpty) {


            _entries = entriesState.entries.entries.map((e) => e.value).toList();

            return buildListView(_entries);
          } else if (entriesState.isLoading == false && entriesState.entries.isEmpty) {
            return EmptyContent();
          } else {
            //TODO pass meaningful error message
            return ErrorContent();
          }
        },
      ),
    );
  }

  Widget buildListView(List<MyEntry> _entries) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
        itemCount: _entries.length,
        itemBuilder: (BuildContext context, int index) {
          final MyEntry _entry = _entries[index];
          //TODO build filtered view options
          return EntryListTile(entry: _entry);
        });
  }
}
