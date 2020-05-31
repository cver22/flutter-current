import 'package:expenses/blocs/entries_bloc/bloc.dart';
import 'package:expenses/blocs/entries_bloc/entries_bloc.dart';
import 'package:expenses/blocs/logs_bloc/bloc.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/entry/entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:flutter/material.dart';

class CategoryPicker extends StatefulWidget {
  //TODO probably refactor for this to just access the blocs from context
  //TODO refactor the dropdown to follow the pattern I used in the log picker
  //TODO error checking if no categories or subcategories are present
  const CategoryPicker({Key key,
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
  //TODO refactor picker to allow editing of categories in the log
  LogsBloc _logsBloc;
  EntriesBloc _entriesBloc;
  Entry _entry;
  Log _log;
  Map<String, MyCategory> _categories;
  Map<String, MySubcategory> _subcategories;
  MyCategory _category; //TODO set editable default category
  MySubcategory _subcategory; //TODO set editable default category

  @override
  void initState() {
    super.initState();
    _entriesBloc = widget.entriesBloc;
    _logsBloc = widget.logsBloc;
    _entry = widget.entry;
    _log = widget.log;

    //initialize category from existing entry
    if (widget.entry?.category != null) {
      String categoryId = widget.entry.category;
      _category = _log.categories[categoryId];
    }

    //initialize subcategory from existing entry
    if (widget.entry?.subcategory != null) {
      String subcategoryId = widget.entry.subcategory;
      _subcategory = _log.subcategories[subcategoryId];
    }
  }

  void _submit() {
    _entry =
        _entry.copyWith(category: _category.id, subcategory: _subcategory.id);
    _entriesBloc..add(EntryUpdated(entry: _entry));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _categoryDropDown(),
        //only shows subcategories after selection of category
        _subcategories.length > 0 ? _subcategoryDropDown() : Container(),
      ],
    );
  }

  Widget _categoryDropDown() {
    return DropdownButton<MyCategory>(
      value: _category,
      onChanged: (MyCategory value) {
        setState(() {
          _category = value;
          String parentCategoryId = _category.id;

          //populates subcategory dropdown based on category chosen
          _log.subcategories.forEach((key, subcategory) =>
          subcategory.parentCategoryId == parentCategoryId ?
          _subcategories[key] = subcategory : null);
          _submit();
        });
      },
      items: _categories.map((id, category) {
        return MapEntry(id, DropdownMenuItem<MyCategory>(
        value: category,
        child: Text(
        category.name,
        style: TextStyle(color: Colors.black),)
        ,
        ));
      }).values.toList(),
    );
  }

  Widget _subcategoryDropDown() {
    return DropdownButton<MySubcategory>(
      value: _subcategory,
      onChanged: (MySubcategory value) {
        setState(() {
          _subcategory = value;
          _submit();
        });
      },
      items: _subcategories.map((id, subcategory) {
        return MapEntry(id, DropdownMenuItem<MySubcategory>(
          value: subcategory,
          child: Text(
            subcategory.name,
            style: TextStyle(color: Colors.black),
          ),
        ));
      }).values.toList(),
    );
  }
}
