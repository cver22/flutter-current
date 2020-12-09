import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/app/common_widgets/error_widget.dart';
import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/entry/entry_model/entries_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/entry/entry_screen/entry_list_tile.dart';
import 'package:expenses/env.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/maybe.dart';
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
        onPressed: () {
          //TODO can probably abstract away to either settings model or to settings actions, i think model would be better, only update if needed
          AppState state = Env.store.state;
          String defaultLogId = state.settingsState.settings.value.defaultLogId;
          if (defaultLogId == null || !state.logsState.logs.containsKey(defaultLogId)) {
            //if log is not present, sets the default log to the first on the log list and notifies the user
            defaultLogId = state.logsState.logs.values.first.id;
            Env.store.dispatch(UpdateSettings(
                settings: Maybe.some(state.settingsState.settings.value.copyWith(defaultLogId: defaultLogId))));

            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Log does not exist, default to first log"),
            ));
          }

          Env.store.dispatch(SetNewSelectedEntry(logId: defaultLogId));
          Get.toNamed(ExpenseRoutes.addEditEntries);
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
            return ModalLoadingIndicator(loadingMessage: 'Loading your entries...', activate: true);
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
