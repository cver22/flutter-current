import 'package:expenses/env.dart';
import 'package:expenses/models/categories/categories_state.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/utils.dart';

import 'package:flutter/material.dart';

class CategoryPicker extends StatefulWidget {
  //TODO refactor the dropdown to follow the pattern I used in the log picker
  //TODO error checking if no categories or subcategories are present
  const CategoryPicker({Key key, @required this.entry}) : super(key: key);

  final MyEntry entry;

  @override
  _CategoryPickerState createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  //TODO refactor picker to allow editing of categories in the log
  MyEntry _entry;
  Log _log;
  MyCategory _category; //TODO set editable default category
  MySubcategory _subcategory; //TODO set editable default category

  @override
  Widget build(BuildContext context) {
    //TODO pass entry and default log to get categories
    _entry = widget?.entry;
    _log = Env.store.state.logsState.logs[_entry.logId];



    return ConnectState<CategoriesState>(
        where: notIdentical,
        map: (state) => state.categoriesState,
        builder: (categoriesState) {
          //initialize category from existing entry
          if (_entry?.category != null) {
            String categoryId = _entry.category;
            _category =
                _log.categories.firstWhere((element) => element.id == categoryId);
          } else {
            _category = null;
          }

          //initialize subcategory from existing entry
          if (_entry?.subcategory != null) {
            String subcategoryId = _entry.subcategory;
            _subcategory = _log.subcategories
                .firstWhere((element) => element.id == subcategoryId);
          } else {
            _subcategory = null;
          }

          //TODO I suspect this could be _categories = _log?.categories;
          if (_log?.categories != null) {
            Env.store.dispatch(
                UpdateCategoriesStatus(categories: Maybe.some(_log.categories)));
          }

          return Column(
            children: <Widget>[
              categoriesState.categories.isSome
                  ? _categoryDropDown(categoriesState)
                  : Container(),
              //only shows subcategories after selection of category
              categoriesState.subcategories.isSome && _category != null
                  ? _subcategoryDropDown(categoriesState)
                  : Container(),
            ],
          );
        });
  }

  Widget _categoryDropDown(CategoriesState categoriesState) {
    return DropdownButton<MyCategory>(
      value: _category,
      onChanged: (MyCategory value) {
        setState(() {
          _subcategory = null;

          _category = value;

          //populates subcategory dropdown based on category chosen
          Env.store.dispatch(UpdateCategoriesStatus(
              subcategories: Maybe.some(
            _log.subcategories
                .where((e) => e.parentCategoryId == _category.id)
                .toList(),
          )));
          Env.store.dispatch(ChangeEntryCategories(category: _category.id));
        });
      },
      items: categoriesState.categories.value.map((category) {
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

  Widget _subcategoryDropDown(CategoriesState categoriesState) {
    return DropdownButton<MySubcategory>(
      value: _subcategory,
      onChanged: (MySubcategory subcategory) {
        setState(() {
          Env.store.dispatch(UpdateSelectedEntry(subcategory: subcategory.id));
        });
      },
      items: categoriesState.subcategories.value.map((subcategory) {
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
}
