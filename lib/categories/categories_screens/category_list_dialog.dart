import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_model/my_subcategory/my_subcategory.dart';
import 'package:expenses/categories/categories_screens/category_list_tile.dart';
import 'package:expenses/categories/categories_screens/edit_category_dialog.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/settings/settings_model/settings.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/keys.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//This widget is used in all category and subcategory lists throughout the application

class CategoryListDialog extends StatefulWidget {
  final CategoryOrSubcategory categoryOrSubcategory;
  final VoidCallback backChevron;
  final Log log;
  final SettingsLogEntry settingsLogEntry;

  CategoryListDialog(
      {Key key, @required this.categoryOrSubcategory, this.backChevron, this.log, @required this.settingsLogEntry})
      : super(key: key);

  @override
  _CategoryListDialogState createState() => _CategoryListDialogState();
}

class _CategoryListDialogState extends State<CategoryListDialog> {
  @override
  Widget build(BuildContext context) {
    List<MyCategory> _categories = [];
    List<MySubcategory> _subcategories = [];
    SettingsLogEntry _settingsLogEntry = widget?.settingsLogEntry;
    CategoryOrSubcategory _categoryOrSubcategory = widget?.categoryOrSubcategory;
    Log log = widget?.log;

    //determines which list is passed based on if it comes from default or the entry
    switch (widget.settingsLogEntry) {
      case SettingsLogEntry.settings:
        Settings _settings = Env.store.state.settingsState.settings.value;
        _categories = _settings.defaultCategories;
        _subcategories = _settings.defaultSubcategories;
        break;
      case SettingsLogEntry.log:
        if (log != null) {
          _categories = widget.log.categories;
          if (_categoryOrSubcategory == CategoryOrSubcategory.subcategory) {
            _subcategories = log.subcategories;
          }
        }
        break;
      case SettingsLogEntry.entry:
        if (log != null) {
          _categories = log.categories;
          if (_categoryOrSubcategory == CategoryOrSubcategory.subcategory) {
            _subcategories = log.subcategories
                .where((element) =>
                    element.parentCategoryId == Env.store.state.entriesState.selectedEntry.value.categoryId)
                .toList();
          }
        }
        break;
    }

    if (_settingsLogEntry == SettingsLogEntry.settings) {
      return ConnectState(
          where: notIdentical,
          map: (state) => state.settingsState,
          builder: (state) {
            print('the current state is $state');
            return buildDialog(_categories, _subcategories, context, _settingsLogEntry, _categoryOrSubcategory, null);
          });
    } else {
      return ConnectState(
          where: notIdentical,
          map: (state) => state.logsState,
          builder: (state) {
            print('the current state is $state');
            return buildDialog(_categories, _subcategories, context, _settingsLogEntry, _categoryOrSubcategory, log);
          });
    }
  }

  Dialog buildDialog(List<MyCategory> _categories, List<MySubcategory> _subcategories, BuildContext context,
      SettingsLogEntry _settingsLogEntry, CategoryOrSubcategory _categoryOrSubcategory, Log log) {
    return Dialog(
      //TODO move to constants
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),

      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chevron_left),
                //if no back action is passed, automatically set to pop context
                onPressed: widget.backChevron ?? () => Get.back(),
              ),
              Text(
                _categoryOrSubcategory == CategoryOrSubcategory.category ? CATEGORY : SUBCATEGORY,
                //TODO currently uses the database constants to label the dialog, will need to change to if function that utilizes the constants to trigger the UI constants
                style: TextStyle(fontSize: 20.0),
              ),
              IconButton(
                icon: Icon(Icons.add),
                //if no back action is passed, automatically set to pop context
                onPressed: () => _addNew(_categories, _subcategories, _settingsLogEntry, _categoryOrSubcategory, log),
              ),
            ],
          ),
          //shows this list view if the category list comes from the log
          _categoryOrSubcategoryListView(_categories, _subcategories, context, _settingsLogEntry, log),
        ],
      ),
    );
  }

  Widget _categoryOrSubcategoryListView(List<MyCategory> _categories, List<MySubcategory> _subcategories,
      BuildContext context, SettingsLogEntry _settingsLogEntry, Log log) {
    return Expanded(
      flex: 1,
      child: ListView(
          shrinkWrap: true,
          //TODO implement onReorder
          children: widget.categoryOrSubcategory == CategoryOrSubcategory.subcategory
              ? _subcategoryList(_subcategories, _categories, context, _settingsLogEntry, log)
              : _categoryList(_categories, context, _settingsLogEntry, log)),
    );
  }

  List<CategoryListTile> _categoryList(
      List<MyCategory> _categories, BuildContext context, SettingsLogEntry setLogEnt, Log log) {
    return _categories
        .map(
          (MyCategory category) => CategoryListTile(
            category: category,
            onLongPress: () => _switchCatOnLongPress(category, setLogEnt),
            onTap: () => _switchOnCatTap(category, setLogEnt, log),
          ),
        )
        .toList();
  }

  Future<dynamic> _switchOnCatTap(MyCategory category, SettingsLogEntry setLogEnt, Log log) {
    switch (setLogEnt) {
      case SettingsLogEntry.settings:
        return _settingsAddEditCategory(category);
        break;
      case SettingsLogEntry.entry:
        return _entrySelectCategory(category);
        break;
      case SettingsLogEntry.log:
        return _logAddEditCategory(category, log);
        break;
      default:
        print('Error encountered loading Cat on Tap');
        return null;
        break;
    }
  }

  Future<dynamic> _settingsAddEditCategory(MyCategory category) {
    Settings settings = Env.store.state.settingsState.settings.value;
    return Get.dialog(
      EditCategoryDialog(
        save: (name, emojiChar, unused) => {
          setState(() {
            Env.store.dispatch(
              UpdateSettings(
                settings: Maybe.maybe(
                  settings.editSettingCategories(
                    settings: settings,
                    category: category.copyWith(name: name, emojiChar: emojiChar),
                  ),
                ),
              ),
            );
          })
        },

        /*setDefault: (category) => {
          Env.logsFetcher.updateLog(log.setCategoryDefault(log: log, category: category)),
        },*/
        delete: (id) => {
          setState(() {
            List<MyCategory> categories = settings.defaultCategories;
            if (categories.length > 2) {
              categories = categories.where((element) => element.id != category.id).toList();
              Env.store
                  .dispatch(UpdateSettings(settings: Maybe.some(settings.copyWith(defaultCategories: categories))));
            } else {
              //TODO error message, must have at least one category
            }
          })
        },
        category: category,
        categories: settings.defaultCategories,
        categoryOrSubcategory: CategoryOrSubcategory.category,
      ),
    );
  }

  Future<dynamic> _entrySelectCategory(MyCategory category) {
    Env.store.dispatch(ChangeEntryCategories(category: category.id));
    Get.back();
    return Get.dialog(
      CategoryListDialog(
        categoryOrSubcategory: CategoryOrSubcategory.subcategory,
        log: widget.log,
        key: ExpenseKeys.subcategoriesDialog,
        settingsLogEntry: SettingsLogEntry.entry,
        backChevron: () => {
          Get.back(),
          Get.dialog(
            CategoryListDialog(
              categoryOrSubcategory: CategoryOrSubcategory.category,
              log: Env.store.state.logsState.logs[Env.store.state.entriesState.selectedEntry.value.logId],
              key: ExpenseKeys.categoriesDialog,
              settingsLogEntry: SettingsLogEntry.entry,
            ),
          ),
        },
      ),
    );
  }

  Future<dynamic> _logAddEditCategory(MyCategory category, Log log) {
    List<MyCategory> categories = log.categories;
    return Get.dialog(
      EditCategoryDialog(
        save: (name, emojiChar, parentCategoryId) => {
          setState(() {
            Env.logsFetcher.updateLog(log.addEditLogCategories(
              log: log,
              category: category.copyWith(name: name, emojiChar: emojiChar),
            ));
          })
        },
        //TODO default function
        delete: (id) => {
          setState(() {
            if (categories.length > 2) {
              categories = categories.where((element) => element.id != category.id).toList();
              Env.logsFetcher.updateLog(log.copyWith(categories: categories));
            } else {
              //TODO error message, must have at least one category, can't delete defualt, cant delete no category
            }
          })
        },
        category: category,
        categories: categories,
        categoryOrSubcategory: CategoryOrSubcategory.category,
      ),
    );
  }

  Future<dynamic> _switchCatOnLongPress(MyCategory category, SettingsLogEntry setLogEnt) {
    //methods for settings and logs onLongPress not required at this time
    switch (setLogEnt) {
      /*case SettingsLogEntry.settings:
        return null; //not required
        break;*/
      case SettingsLogEntry.entry:
        return _entryAddEditCategory(category);
        break;
      /*case SettingsLogEntry.log:
        return null; //not required
        break;*/
      default:
        print('Error encountered loading Cat On Long Press');
        return null;
        break;
    }
  }

  Future<dynamic> _entryAddEditCategory(MyCategory category) {
    return Get.dialog(
      EditCategoryDialog(
        save: (name, emojiChar, unused) => Env.logsFetcher.updateLog(widget.log
            .addEditLogCategories(log: widget.log, category: category.copyWith(name: name, emojiChar: emojiChar))),

        /*setDefault: (category) => {
          Env.logsFetcher.updateLog(log.setCategoryDefault(log: log, category: category)),
        },*/

        //TODO create delete function
        category: category,
        categoryOrSubcategory: CategoryOrSubcategory.category,
      ),
    );
  }

  List<CategoryListTile> _subcategoryList(List<MySubcategory> _subcategories, List<MyCategory> _categories,
      BuildContext context, SettingsLogEntry setLogEnt, Log log) {
    List<MySubcategory> _organizedSubcategories = [];
    if (setLogEnt == SettingsLogEntry.settings || setLogEnt == SettingsLogEntry.log) {
      for (int i = 0; i < _categories.length; i++) {
        //Adds title to setting subcategory list
        _organizedSubcategories
            .add(MySubcategory(parentCategoryId: null, name: _categories[i].name, emojiChar: _categories[i].emojiChar));
        for (int j = 0; j < _subcategories.length; j++) {
          //Adds subcategories organized by category for settings
          if (_subcategories[j].parentCategoryId == _categories[i].id) {
            _organizedSubcategories.add(_subcategories[j]);
          }
        }
      }
    } else {
      _organizedSubcategories = _subcategories;
    }

    return _organizedSubcategories
        .map(
          (MySubcategory subcategory) => CategoryListTile(
            category: subcategory,
            onTap: subcategory.parentCategoryId == null
                ? null
                : () => _switchSubOnTap(subcategory, _categories, setLogEnt, log),
            onLongPress: subcategory.parentCategoryId == null
                ? null
                : () => _switchSubcategoryOnLongPress(subcategory, _categories, setLogEnt),
            heading: subcategory.parentCategoryId == null ? true : false,
          ),
        )
        .toList();
  }

  Future<dynamic> _switchSubOnTap(
      MySubcategory subcategory, List<MyCategory> _categories, SettingsLogEntry setLogEnt, Log log) {
    switch (setLogEnt) {
      case SettingsLogEntry.settings:
        return _settingsAddEditSubcategory(subcategory, _categories);
        break;
      case SettingsLogEntry.entry:
        return _entrySelectSubcategory(subcategory);
        break;
      case SettingsLogEntry.log:
        return _logAddEditSubcategory(subcategory, _categories, log);
        break;
      default:
        print('Error encountered loading Sub On Tap');
        return null;
        break;
    }
  }

  Future<dynamic> _logAddEditSubcategory(MySubcategory subcategory, List<MyCategory> _categories, Log log) {
    return Get.dialog(
      EditCategoryDialog(
        categories: _categories,
        save: (name, emojiChar, parentCategoryId) => {
          setState(() {
            Env.logsFetcher.updateLog(log.addEditLogSubcategories(
              log: log,
              subcategory: subcategory.copyWith(name: name, emojiChar: emojiChar, parentCategoryId: parentCategoryId),
            ));
          })
        },
        //TODO default function
        delete: (id) => {
          setState(() {
            List<MySubcategory> subcategories = [];
            subcategories = log.subcategories.where((element) => element.id != subcategory.id).toList();
            Env.logsFetcher.updateLog(log.copyWith(subcategories: subcategories));
          })
        },
        subcategory: subcategory,
        categoryOrSubcategory: CategoryOrSubcategory.subcategory,
      ),
    );
  }

  Future<dynamic> _settingsAddEditSubcategory(MySubcategory subcategory, List<MyCategory> _categories) {
    Settings settings = Env.store.state.settingsState.settings.value;
    return Get.dialog(
      EditCategoryDialog(
        categories: _categories,
        save: (name, emojiChar, parentCategoryId) => {
          setState(() {
            Env.store.dispatch(
              UpdateSettings(
                settings: Maybe.maybe(
                  settings.editSettingSubcategories(
                    settings: settings,
                    subcategory:
                        subcategory.copyWith(name: name, emojiChar: emojiChar, parentCategoryId: parentCategoryId),
                  ),
                ),
              ),
            );
          })
        },
        //TODO default function
        delete: (id) => {
          setState(() {
            List<MySubcategory> subcategories = [];
            subcategories = settings.defaultSubcategories.where((element) => element.id != subcategory.id).toList();
            Env.store
                .dispatch(UpdateSettings(settings: Maybe.some(settings.copyWith(defaultSubcategories: subcategories))));
          })
        },
        subcategory: subcategory,
        categoryOrSubcategory: CategoryOrSubcategory.subcategory,
      ),
    );
  }

  Future<void> _entrySelectSubcategory(MySubcategory subcategory) async {
    //onTap method for Entry Subcategories
    Env.store.dispatch(UpdateSelectedEntry(subcategory: subcategory.id));
    Get.back();
  }

  Future<dynamic> _switchSubcategoryOnLongPress(
      MySubcategory subcategory, List<MyCategory> _categories, SettingsLogEntry setLogEnt) {
    //methods for settings and logs onLongPress not required at this time
    switch (setLogEnt) {
      /*case SettingsLogEntry.settings:
        return null; //not required
        break;*/
      case SettingsLogEntry.entry:
        return _entryAddEditSubcategory(subcategory, _categories);
        break;
      /* case SettingsLogEntry.log:
        return null; //not required
        break;*/
      default:
        print('Error encountered loading Sub On Long Press or not required');
        return null;
        break;
    }
  }

  Future<dynamic> _entryAddEditSubcategory(MySubcategory subcategory, List<MyCategory> _categories) {
    return Get.dialog(
      EditCategoryDialog(
        categories: _categories,
        save: (name, emojiChar, parentCategoryId) => {
          setState(() {
            Env.logsFetcher.updateLog(widget.log.addEditLogSubcategories(
                log: widget.log,
                subcategory:
                    subcategory.copyWith(name: name, emojiChar: emojiChar, parentCategoryId: parentCategoryId)));
          })
        },

        //TODO default function

        //TODO create delete function
        initialParent: Env.store.state.entriesState.selectedEntry.value.categoryId,
        subcategory: subcategory,
        categoryOrSubcategory: CategoryOrSubcategory.subcategory,
      ),
    );
  }

  Future<dynamic> _addNew(List<MyCategory> _categories, List<MySubcategory> _subcategories,
      SettingsLogEntry settingsLogEntry, CategoryOrSubcategory categoryOrSubcategory, Log log) {
    if (categoryOrSubcategory == CategoryOrSubcategory.category) {
      MyCategory newCategory = MyCategory();
      switch (settingsLogEntry) {
        case SettingsLogEntry.settings:
          return _settingsAddEditCategory(newCategory);
          break;
        case SettingsLogEntry.entry:
          return _entryAddEditCategory(newCategory);
          break;
        case SettingsLogEntry.log:
          return _entryAddEditCategory(newCategory);
          break;
        default:
          print('Error encountered trying to add new category ');
          return null;
          break;
      }
    } else {
      MySubcategory newSubcategory = MySubcategory();
      switch (settingsLogEntry) {
        case SettingsLogEntry.settings:
          return _settingsAddEditSubcategory(newSubcategory, _categories);
          break;
        case SettingsLogEntry.entry:
          return _entryAddEditSubcategory(newSubcategory, _categories);
          break;
        case SettingsLogEntry.log:
          return _logAddEditSubcategory(newSubcategory, _categories, log);
          break;
        default:
          print('Error encountered trying to add new subcategory');
          return null;
          break;
      }
    }
  }
}
