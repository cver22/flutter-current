import 'package:expenses/env.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:flutter/material.dart';

class EntryListTile extends StatelessWidget {
  final MyEntry entry;

  const EntryListTile({Key key, @required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.category),
      title: Text(entry.comment),
      subtitle: Text('Category, subcategories, tags'),
      trailing: Text('\$ ${entry.amount.toString()}'),
      onTap: () => {
        Env.store.dispatch(SelectEntry(entryId: entry.id)),
        Navigator.pushNamed(context, ExpenseRoutes.addEditEntries),
      },
    );
  }
}
