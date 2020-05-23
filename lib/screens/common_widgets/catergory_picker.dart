import 'package:expenses/blocs/entries_bloc/entries_bloc.dart';
import 'package:expenses/blocs/logs_bloc/bloc.dart';
import 'package:expenses/models/categories/category.dart';
import 'package:expenses/models/categories/subcategory.dart';
import 'package:expenses/models/entry/entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:flutter/material.dart';

class CategoryPicker extends StatefulWidget {
  //TODO probably refactor for this to just access the blocs from context
  //TODO refactor the dropdown to follow the pattern I used in the log picker
  const CategoryPicker(
      {Key key,
      @required this.logsBloc,
      @required this.entriesBloc,
      @required this.entry,
      @required this.log})
      : super(key: key);

  final LogsBloc logsBloc;
  final EntriesBloc entriesBloc;
  final Entry entry;
  final Log log;

  @override
  _CategoryPickerState createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  LogsBloc _logsBloc;
  EntriesBloc _entriesBloc;
  Entry _entry;
  Log _log;

  //TODO set initial categories from an existing entry based on the id of the cat / subcat
  Category _category; //TODO default to misc
  Subcategory _subcategory; // TODO default to misc

  @override
  void initState() {
    super.initState();
    _entriesBloc = widget.entriesBloc;
    _logsBloc = widget.logsBloc;
    _entry = widget.entry;
    _log = widget.log;
  }

  @override
  Widget build(BuildContext context) {
    List<Category> _categories = [];
    List<Subcategory> _subcategories = [];

    for (int i = 0; i < _log.categories.categories.length; i++) {
      _categories.add(_log.categories.categories[i]);
    }

    return DropdownButton<Category>(
      value: _category,
      onChanged: (Category value) {
        setState(() {
          _category = value;
          //TODO get index of category and return subcategories list using for loop similar to above
        });
      },
      items: _categories.map((Category category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Text(
            category.name,
            style: TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
    );
  }
}
