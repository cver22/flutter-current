import 'package:expenses/env.dart';
import 'package:expenses/models/entry/entries_state.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/screens/common_widgets/empty_content.dart';
import 'package:expenses/screens/common_widgets/error_widget.dart';
import 'package:expenses/screens/common_widgets/loading_indicator.dart';
import 'package:expenses/screens/entries/entry_list_tile.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';



class EntriesScreen extends StatefulWidget {
  const EntriesScreen({Key key}) : super(key: key);

  @override
  _EntriesScreenState createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  List<MyEntry> _entries = [];


  @override
  Widget build(BuildContext context) {
    Env.entriesFetcher.loadEntries();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        //TODO pass default log or retrieve from state
        onPressed: () =>
            Navigator.pushNamed(context, ExpenseRoutes.addEditEntries),
        child: Icon(Icons.add),
      ),
      body: ConnectState<EntriesState>(
        where: notIdentical,
        map: (state) => state.entriesState,
        builder: (entriesState) {
          print('Rendering entries screen');
          print('Entries State: $entriesState');

          if (entriesState.isLoading == true) {
            return LoadingIndicator(loadingMessage: 'Loading your entries...');
          } else if (entriesState.isLoading == false &&
              entriesState.entries.isNotEmpty) {
            //Only shows logs that have not been "deleted"
            //TODO can I move this logic to the state object and render this widget stateless?
            _entries = entriesState.entries.entries
                .map((e) => e.value)
                .where((e) => e.active == true)
                .toList();

            return buildListView();
          } else if (entriesState.isLoading == false &&
              entriesState.entries.isEmpty) {
            return EmptyContent();
          } else {
            //TODO pass meaningful error message
            return ErrorContent();
          }
        },
      ),
    );
  }

  Widget buildListView() {
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
