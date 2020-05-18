import 'package:expenses/models/entry/entry.dart';
import 'package:flutter/material.dart';

class EntryListTile extends StatelessWidget {

  final Entry entry;
  final VoidCallback onTap;

  const EntryListTile({Key key, @required this.entry, this.onTap}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry.entryName),
      subtitle: Text('Category, subcategories, tags'),
      trailing: Text(entry.amount.toString()),
      onTap: onTap,
    );
  }
}
