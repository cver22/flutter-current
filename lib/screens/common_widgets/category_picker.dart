import 'package:expenses/env.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:flutter/material.dart';

class CategoryPicker extends StatefulWidget {
  //TODO refactor the dropdown to follow the pattern I used in the log picker
  //TODO error checking if no categories or subcategories are present
  const CategoryPicker({Key key, @required this.log}) : super(key: key);

  final Log log;

  @override
  _CategoryPickerState createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  //TODO refactor picker to allow editing of categories in the log
  MyEntry _entry;
  Log _log;
  List<MyCategory> _categories;
  List<MySubcategory> _subcategories;
  MyCategory _category; //TODO set editable default category
  MySubcategory _subcategory; //TODO set editable default category

  @override
  void initState() {
    super.initState();
    _log = widget?.log;
    print('category log: $_log');
    //TODO pass entry and default log to get categories
  }

  @override
  Widget build(BuildContext context) {
    //initialize category from existing entry
    if (_entry?.category != null) {
      String categoryId = _entry.category;
      _category =
          _log.categories.firstWhere((element) => element.id == categoryId);
    }

    //initialize subcategory from existing entry
    if (_entry?.subcategory != null) {
      String subcategoryId = _entry.subcategory;
      _subcategory = _log.subcategories
          .firstWhere((element) => element.id == subcategoryId);
    }
    if (widget.log?.categories != null) {
      _categories = widget.log.categories;
    }
    return Column(
      children: <Widget>[
        _categories != null ? _categoryDropDown() : Container(),
        //only shows subcategories after selection of category
        _subcategories != null ? _subcategoryDropDown() : Container(),
      ],
    );
  }

  Widget _categoryDropDown() {
    return DropdownButton<MyCategory>(
      value: _category,
      onChanged: (MyCategory value) {
        setState(() {
          _subcategory = null;
          _category = value;
          _updateEntry();

          //populates subcategory dropdown based on category chosen
          _subcategories = _log.subcategories
              .where((e) => e.parentCategoryId == _category.id)
              .toList();
        });
      },
      items: _categories.map((category) {
        return DropdownMenuItem<MyCategory>(
          value: category,
          child: Text(
            category.name,
            style: TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
    );
  }

  Widget _subcategoryDropDown() {
    return DropdownButton<MySubcategory>(
      value: _subcategory,
      onChanged: (MySubcategory value) {
        setState(() {
          _subcategory = value;
          _updateEntry();
        });
      },
      items: _subcategories.map((subcategory) {
        return DropdownMenuItem<MySubcategory>(
          value: subcategory,
          child: Text(
            subcategory.name,
            style: TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
    );
  }

  void _updateEntry() {
    Env.store.dispatch(UpdateSelectedEntry(category: _category?.id, subcategory: _subcategory?.id));
  }
}