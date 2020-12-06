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
  List<MyCategory> _categories = [];
  List<MySubcategory> _subcategories = [];
  List<MySubcategory> _organizedSubcategories = [];
  SettingsLogEntry _settingsLogEntry;
  CategoryOrSubcategory _categoryOrSubcategory;
  Log _log;
  Settings _settings;

  @override
  void initState() {
    _settingsLogEntry = widget?.settingsLogEntry;
    _categoryOrSubcategory = widget?.categoryOrSubcategory;
    _log = widget?.log;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //determines which list is passed based on if it comes from default or the entry

    if (_settingsLogEntry == SettingsLogEntry.settings) {
      return ConnectState(
          where: notIdentical,
          map: (state) => state.settingsState,
          builder: (state) {
            _settings = Env.store.state.settingsState.settings.value;
            _categories = _settings.defaultCategories;
            _subcategories = _settings.defaultSubcategories;
            print('the current state is $state');
            return buildDialog(context);
          });
    } else {
      return ConnectState(
          where: notIdentical,
          map: (state) => state.logsState,
          builder: (state) {
            if (_log != null) {
              _categories = _log.categories;

              if (_categoryOrSubcategory == CategoryOrSubcategory.subcategory) {
                _subcategories = _settingsLogEntry == SettingsLogEntry.log
                    ? _log.subcategories
                    : _log.subcategories
                        .where((element) =>
                            element.parentCategoryId == Env.store.state.singleEntryState.selectedEntry.value.categoryId)
                        .toList();
              }
            } else {
              print('An error has occurred in category_list_dialog at connect state');
            }
            print('the current state is $state');
            return buildDialog(context);
          });
    }
  }

  Dialog buildDialog(BuildContext context) {
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
                onPressed: () => _addNew(),
              ),
            ],
          ),
          //shows this list view if the category list comes from the log
          _categoryOrSubcategoryListView(context),
        ],
      ),
    );
  }

  Widget _categoryOrSubcategoryListView(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ReorderableListView(
          scrollController: PrimaryScrollController.of(context) ?? ScrollController(),
          onReorder: _onReorder,
          //TODO implement onReorder
          children: widget.categoryOrSubcategory == CategoryOrSubcategory.subcategory
              ? _subcategoryList(context)
              : _categoryList(context)),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {

    //TODO, rethink this

    List<MySubcategory> _allSubcategories = [];
    bool reOrdered = false;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    print('initial oldIndex $oldIndex and initial newIndex $newIndex');

    //ensures headings can not be moved
    if (_categoryOrSubcategory == CategoryOrSubcategory.subcategory &&
        _organizedSubcategories[oldIndex].parentCategoryId != null) {
      // Modifies the new and old index to reflect the position of the element in the original _subcategories
      _allSubcategories = _log?.subcategories ?? _settings.defaultSubcategories;

      if (_settingsLogEntry != SettingsLogEntry.entry) {
        int headings = 0;
        for (int i = 0; i < _organizedSubcategories.length; i++) {
          if (_organizedSubcategories[i].parentCategoryId == null) {
            headings += 1;
          } else if (i == newIndex) {
            newIndex = newIndex - headings;
          }
        }
        reOrdered = true;
      } else {
        //reorder entry subcategories
        MySubcategory subcategoryBefore;
        MySubcategory subcategoryAfter;
        if (newIndex == 0 && _organizedSubcategories.length > 1) {
          subcategoryAfter = _organizedSubcategories[newIndex + 1];
          newIndex = _allSubcategories.indexOf(subcategoryAfter) - 1;
        } else if (newIndex <= _organizedSubcategories.length && _organizedSubcategories.length > 1) {
          subcategoryBefore = _organizedSubcategories[newIndex - 1];
          newIndex = _allSubcategories.indexOf(subcategoryBefore) + 1;
        }
        reOrdered = true;
      }

      if (reOrdered) {
        oldIndex = _allSubcategories.indexOf(_organizedSubcategories[oldIndex]);
        print('modified oldIndex $oldIndex and modified newIndex $newIndex');

        MySubcategory subcategory = _allSubcategories.removeAt(oldIndex);
        _allSubcategories.insert(newIndex, subcategory);
      }
    } else if (_categoryOrSubcategory == CategoryOrSubcategory.category) {
      MyCategory category = _categories.removeAt(oldIndex);
      _categories.insert(newIndex, category);
      reOrdered = true;
    } else {
      print('That tile can\'t be reordered');
    }

    //save reordered list to the appropriate location
    if (reOrdered) {
      switch (_settingsLogEntry) {
        case SettingsLogEntry.settings:
          Env.store.dispatch(UpdateSettings(
              settings: Maybe.some(
                  _settings.copyWith(defaultCategories: _categories, defaultSubcategories: _allSubcategories))));
          break;
        case SettingsLogEntry.entry:
          Env.logsFetcher.updateLog(_log.copyWith(categories: _categories, subcategories: _allSubcategories));
          break;
        case SettingsLogEntry.log:
          Env.logsFetcher.updateLog(_log.copyWith(categories: _categories, subcategories: _allSubcategories));
          break;
        default:
          print('Error saving new subcategories');
          break;
      }
    }
  }

  List<CategoryListTile> _categoryList(BuildContext context) {
    return _categories
        .map(
          (MyCategory category) => CategoryListTile(
            key: Key(category.id),
            category: category,
            onTapEdit: () => _switchCatOnTapEdit(category),
            onTap: () => _switchOnCatTap(category),
          ),
        )
        .toList();
  }

  Future<dynamic> _switchOnCatTap(MyCategory category) {
    switch (_settingsLogEntry) {
      case SettingsLogEntry.settings:
        //not used
        break;
      case SettingsLogEntry.entry:
        return _entrySelectCategory(category);
        break;
      case SettingsLogEntry.log:
        // not used
        break;
      default:
        print('Error encountered loading Cat on Tap');
        return null;
        break;
    }
  }

  Future<dynamic> _settingsAddEditCategory(MyCategory category) {
    return Get.dialog(
      EditCategoryDialog(
        save: (name, emojiChar, unused) => {
          setState(() {
            Env.store.dispatch(
              UpdateSettings(
                settings: Maybe.maybe(
                  _settings.editSettingCategories(
                    settings: _settings,
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
            List<MyCategory> categories = _settings.defaultCategories;
            if (categories.length > 2) {
              categories = categories.where((element) => element.id != category.id).toList();
              Env.store
                  .dispatch(UpdateSettings(settings: Maybe.some(_settings.copyWith(defaultCategories: categories))));
            } else {
              //TODO error message, must have at least one category
            }
          })
        },
        category: category,
        categories: _settings.defaultCategories,
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
              log: Env.store.state.logsState.logs[Env.store.state.singleEntryState.selectedEntry.value.logId],
              key: ExpenseKeys.categoriesDialog,
              settingsLogEntry: SettingsLogEntry.entry,
            ),
          ),
        },
      ),
    );
  }

  Future<dynamic> _logAddEditCategory(MyCategory category) {
    return Get.dialog(
      EditCategoryDialog(
        save: (name, emojiChar, parentCategoryId) => {
          setState(() {
            Env.logsFetcher.updateLog(_log.addEditLogCategories(
              log: _log,
              category: category.copyWith(name: name, emojiChar: emojiChar),
            ));
          })
        },
        //TODO default function
        delete: (id) => {
          setState(() {
            if (_categories.length > 2) {
              _categories = _categories.where((element) => element.id != category.id).toList();
              Env.logsFetcher.updateLog(_log.copyWith(categories: _categories));
            } else {
              //TODO error message, must have at least one category, can't delete defualt, cant delete no category
            }
          })
        },
        category: category,
        categories: _categories,
        categoryOrSubcategory: CategoryOrSubcategory.category,
      ),
    );
  }

  Future<dynamic> _switchCatOnTapEdit(MyCategory category) {
    //methods for settings and logs onLongPress not required at this time
    switch (_settingsLogEntry) {
      case SettingsLogEntry.settings:
        return _settingsAddEditCategory(category);
        break;
      case SettingsLogEntry.entry:
        return _entryAddEditCategory(category);
        break;
      case SettingsLogEntry.log:
        return _logAddEditCategory(category);
        break;
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

  List<CategoryListTile> _subcategoryList(BuildContext context) {
    if (_settingsLogEntry == SettingsLogEntry.settings || _settingsLogEntry == SettingsLogEntry.log) {
      for (int i = 0; i < _categories.length; i++) {
        //Adds title to setting subcategory list
        _organizedSubcategories.add(MySubcategory(
            parentCategoryId: null,
            name: _categories[i].name,
            emojiChar: _categories[i].emojiChar,
            id: _categories[i].id));
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
            key: Key(subcategory.id),
            category: subcategory,
            onTap: subcategory.parentCategoryId == null ? null : () => _switchSubOnTap(subcategory),
            onTapEdit: subcategory.parentCategoryId == null ? null : () => _switchSubcategoryOnTapEdit(subcategory),
            heading: subcategory.parentCategoryId == null ? true : false,
          ),
        )
        .toList();
  }

  Future<dynamic> _switchSubOnTap(MySubcategory subcategory) {
    switch (_settingsLogEntry) {
      case SettingsLogEntry.settings:
        //not required
        break;
      case SettingsLogEntry.entry:
        return _entrySelectSubcategory(subcategory);
        break;
      case SettingsLogEntry.log:
        //not required
        break;
      default:
        print('Error encountered loading Sub On Tap');
        return null;
        break;
    }
  }

  Future<dynamic> _logAddEditSubcategory(MySubcategory subcategory) {
    return Get.dialog(
      EditCategoryDialog(
        categories: _categories,
        save: (name, emojiChar, parentCategoryId) => {
          setState(() {
            Env.logsFetcher.updateLog(_log.addEditLogSubcategories(
              log: _log,
              subcategory: subcategory.copyWith(name: name, emojiChar: emojiChar, parentCategoryId: parentCategoryId),
            ));
          })
        },
        //TODO default function
        delete: (id) => {
          setState(() {
            List<MySubcategory> subcategories = [];
            subcategories = _log.subcategories.where((element) => element.id != subcategory.id).toList();
            Env.logsFetcher.updateLog(_log.copyWith(subcategories: subcategories));
          })
        },
        subcategory: subcategory,
        categoryOrSubcategory: CategoryOrSubcategory.subcategory,
      ),
    );
  }

  Future<dynamic> _settingsAddEditSubcategory(MySubcategory subcategory) {
    return Get.dialog(
      EditCategoryDialog(
        categories: _categories,
        save: (name, emojiChar, parentCategoryId) => {
          setState(() {
            Env.store.dispatch(
              UpdateSettings(
                settings: Maybe.maybe(
                  _settings.editSettingSubcategories(
                    settings: _settings,
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
            subcategories = _settings.defaultSubcategories.where((element) => element.id != subcategory.id).toList();
            Env.store.dispatch(
                UpdateSettings(settings: Maybe.some(_settings.copyWith(defaultSubcategories: subcategories))));
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

  Future<dynamic> _switchSubcategoryOnTapEdit(MySubcategory subcategory) {
    //methods for settings and logs onLongPress not required at this time
    switch (_settingsLogEntry) {
      case SettingsLogEntry.settings:
        return _settingsAddEditSubcategory(subcategory);
        break;
      case SettingsLogEntry.entry:
        return _entryAddEditSubcategory(subcategory);
        break;
      case SettingsLogEntry.log:
        return _logAddEditSubcategory(subcategory);
        break;
      default:
        print('Error encountered loading Sub On Long Press or not required');
        return null;
        break;
    }
  }

  Future<dynamic> _entryAddEditSubcategory(MySubcategory subcategory) {
    return Get.dialog(
      EditCategoryDialog(
        categories: _categories,
        save: (name, emojiChar, parentCategoryId) => {
          setState(() {
            Env.logsFetcher.updateLog(widget.log.addEditLogSubcategories(
                log: _log,
                subcategory:
                    subcategory.copyWith(name: name, emojiChar: emojiChar, parentCategoryId: parentCategoryId)));
          })
        },

        //TODO default function

        //TODO create delete function
        initialParent: Env.store.state.singleEntryState.selectedEntry.value.categoryId,
        subcategory: subcategory,
        categoryOrSubcategory: CategoryOrSubcategory.subcategory,
      ),
    );
  }

  Future<dynamic> _addNew() {
    if (_categoryOrSubcategory == CategoryOrSubcategory.category) {
      MyCategory newCategory = MyCategory(name: null, tagIdFrequency: {});
      switch (_settingsLogEntry) {
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
      MySubcategory newSubcategory = MySubcategory(name: null, parentCategoryId: null);
      switch (_settingsLogEntry) {
        case SettingsLogEntry.settings:
          return _settingsAddEditSubcategory(newSubcategory);
          break;
        case SettingsLogEntry.entry:
          return _entryAddEditSubcategory(newSubcategory);
          break;
        case SettingsLogEntry.log:
          return _logAddEditSubcategory(newSubcategory);
          break;
        default:
          print('Error encountered trying to add new subcategory');
          return null;
          break;
      }
    }
  }
}
