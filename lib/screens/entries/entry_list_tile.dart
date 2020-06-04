import 'package:expenses/models/entry/my_entry.dart';
import 'package:flutter/material.dart';

class EntryListTile extends StatelessWidget {

  final MyEntry entry;
  final VoidCallback onTap;

  const EntryListTile({Key key, @required this.entry, this.onTap}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.category),
      title: Text(entry.comment),
      subtitle: Text('Category, subcategories, tags'),
      trailing: Text('\$ ${entry.amount.toString()}'),
      onTap: onTap,
    );
  }
}
