import 'package:expenses/blocs/entries_bloc/bloc.dart';
import 'package:expenses/models/entry/entry.dart';
import 'package:expenses/screens/common_widgets/empty_content.dart';
import 'package:expenses/screens/entries/add_edit_entries_page.dart';
import 'package:expenses/screens/entries/entry_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EntriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: missing_return
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return BlocProvider.value(
              value: BlocProvider.of<EntriesBloc>(context),
              child: AddEditEntriesPage(),
            );
          }),
        ),
        child: Icon(Icons.add),
      ),
      // ignore: missing_return
      body: BlocBuilder<EntriesBloc, EntriesState>(builder: (context, state) {
        if (state is EntriesLoading) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Text('Loading your logs...'),
            ],
          ));
        } else if (state is EntriesLoaded) {
          final entries = state.entries;
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                entries.isEmpty
                    ? Center(child: EmptyContent())
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: entries.length,
                        // ignore: missing_return
                        itemBuilder: (BuildContext context, int index) {
                          final Entry _entry = entries[index];
                          if(_entry.active == true){
                            return EntryListTile(
                              entry: _entry,
                              onTap: () {},
                            );

                          } else {
                            return Container();
                          }
                        }),
              ],
            ),
          );
        } else if (state is EntriesLoadFailure) {
          return Center(
              child: Column(
            children: <Widget>[
              Icon(Icons.error),
              Text('Something went wrong'),
            ],
          ));
        }
      }),
    );
  }
}
