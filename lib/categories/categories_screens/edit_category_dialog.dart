import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_model/my_subcategory/my_subcategory.dart';
import 'package:expenses/categories/categories_screens/emoji/emoji_picker.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditCategoryDialog extends StatefulWidget {
  final Function(String) delete;
  final Function(MyCategory) setDefault;
  final Function(String, String, String) save; //Category (name, emojiChar, parentCategoryId)
  final MySubcategory subcategory; //TODO needs to handle both categories and subcategories separately
  final MyCategory category;

  //TODO I can likely simplify the category and subcategory system where all parent categories have no parent ID, only subcategories do
  final CategoryOrSubcategory categoryOrSubcategory;
  final List<MyCategory> categories;

  const EditCategoryDialog({
    Key key,
    this.delete,
    this.setDefault,
    @required this.categoryOrSubcategory,
    @required this.save,
    this.subcategory,
    this.category,
    this.categories,
  }) : super(key: key);

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  CategoryOrSubcategory _categoryOrSubcategory;
  MySubcategory _subcategory;
  MyCategory _category;
  TextEditingController _controller;
  String _parentCategoryId;
  String name;
  String id;
  List<MyCategory> _categories = [];
  bool newCategory;
  bool showEmojiGrid;
  String emojiChar;
  MyCategory initialCategory;

  void initState() {
    super.initState();
    showEmojiGrid = false;
    _categories = widget?.categories;
    _categoryOrSubcategory = widget?.categoryOrSubcategory;

    if (_categoryOrSubcategory == CategoryOrSubcategory.category) {
      _category = widget?.category;

      if (_category.name != null) {
        newCategory = false;
        emojiChar = _category.emojiChar ?? '\u{2757}'; // exclamation_mark
        name = _category?.name;
        id = _category?.id;
      } else {
        newCategory = true;
        showEmojiGrid = true;
        emojiChar = '\u{1F4B2}'; // heavy_dollar_sign
        name = '';
      }
    } else {
      _subcategory = widget?.subcategory;

      if (_subcategory.name != null) {
        newCategory = false;
        emojiChar = _subcategory.emojiChar ?? '\u{2757}'; // exclamation_mark
        name = _subcategory?.name;
        id = _subcategory?.id;
        _parentCategoryId = _subcategory?.parentCategoryId;
        if(!_categories.any((element) => element.id == _parentCategoryId)){
          _parentCategoryId = _categories.first.id;
        }
      } else {
        newCategory = true;
        showEmojiGrid = true;
        emojiChar = '\u{1F4B2}'; // heavy_dollar_sign
        name = '';
        _parentCategoryId = _categories.first.id;
      }
      initialCategory = _categories?.firstWhere((e) => e.id == _parentCategoryId);
    }

    _controller = TextEditingController(text: name);
    _controller.addListener(() {
      final textController = _controller.text;
      _controller.value = _controller.value.copyWith(
        text: textController,
        selection: TextSelection(baseOffset: textController.length, extentOffset: textController.length),
        composing: TextRange.empty,
      );
    });
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //TODO implement method to change category of a subcategory
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dialogTitle(_categoryOrSubcategory, newCategory)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: <Widget>[
              //TODO START HERE - Build a selector, will need a widget to show the icon and be a clickable button to select it - Start with just printing it.
              Expanded(
                flex: 1,
                child: RaisedButton(
                  child: Text(
                    emojiChar,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22),
                  ),
                  onPressed: () => setState(() {
                    showEmojiGrid = true;
                  }),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                flex: 5,
                child: TextField(controller: _controller, decoration: InputDecoration(border: OutlineInputBorder())),
              ),
            ],
          ),
          _selectParentCategory(initialCategory),
          SizedBox(height: 10),
          showEmojiGrid
              ? Expanded(
                  child: EmojiPicker(
                      emojiSelection: (emoji) => {
                            setState(() {
                              emojiChar = emoji;
                            })
                          }),
                )
              : Container(),
        ],
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            //TODO implement delete button , safety check the category isn't being used
            FlatButton(
                child: Text('Delete'),
                onPressed: () => {
                      widget?.delete(id),
                      Get.back(),
                    }),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => {
                Get.back(),
              },
            ),

            //TODO implement default category system, option to turn it on
            /*FlatButton(
              child: Text('Set Default'),
              onPressed: () => {
                if (_category?.isDefault == true)
                  {
                    Get.snackbar('${_category.name}', 'is already default'),
                  }
                else
                  {
                    widget.setDefault(_category),
                    Get.snackbar('${_category.name}', 'set to default'),
                  }
              },
            ),*/
            FlatButton(
              child: Text('Save'),
              onPressed: () => {
                //TODO more conditions based on category or subcategory && _category.parentCategoryId != null, _controller.text != _category.name
                if (_controller.text.length > 0)
                  {
                    print('${_controller.text}, $emojiChar, $_parentCategoryId'),
                    widget?.save(_controller.text, emojiChar, _parentCategoryId),
                    Get.back(),
                  }
                else
                  {
                    null,
                  },
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _selectParentCategory(MyCategory initialCategory) {
    return _categoryOrSubcategory == CategoryOrSubcategory.category
        ? Container()
        : Row(
            children: [
              Text('Parent Category: '),
              SizedBox(width: 10),
              DropdownButton<MyCategory>(
                  value: initialCategory,
                  items: _categories.map((MyCategory category) {
                    return DropdownMenuItem<MyCategory>(
                      value: category,
                      child: Text(
                        category.name,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: _onParentCategoryChanged),
            ],
          );
  }

  String dialogTitle(CategoryOrSubcategory _categoryOrSubcategory, bool newCategory) {
    if (_categoryOrSubcategory == CategoryOrSubcategory.category) {
      if (newCategory) {
        return 'New Category';
      } else {
        return 'Edit Category';
      }
    } else {
      if (newCategory) {
        return 'New Subcategory';
      } else {
        return 'Edit Subcategory';
      }
    }
  }

  void _onParentCategoryChanged(MyCategory category) {
    setState(() {
      _parentCategoryId = category.id;
    });
  }
}
