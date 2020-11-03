import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/screens/categories/emoji/emoji_grid.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditCategoryDialog extends StatefulWidget {
  final VoidCallback delete;
  final Function(MyCategory) setDefault;
  final Function(String, String) save; //Category, parentCategoryId
  final MySubcategory category; //TODO needs to handle both categories and subcategories separately
  //TODO I can likely simplify the category and subcategory system where all parent categories have no parent ID, only subcategories do
  final CategoryOrSubcategory categoryOrSubcategory;
  final List<MyCategory> categories;

  const EditCategoryDialog({
    Key key,
    this.delete,
    this.setDefault,
    @required this.categoryOrSubcategory,
    @required this.save,
    @required this.category,
    this.categories,
  }) : super(key: key);

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  CategoryOrSubcategory _categoryOrSubcategory;
  MySubcategory _category;
  TextEditingController _controller;
  String _parentCategoryId;
  List<MyCategory> _categories = [];
  bool newCategory;
  bool showEmojiGrid;

  void initState() {
    super.initState();
    showEmojiGrid = false;
    _categories = widget?.categories;
    _categoryOrSubcategory = widget?.categoryOrSubcategory;
    _category = widget?.category;
    newCategory = true;
    if (_category.name != null) {
      newCategory = false;
    }
    _parentCategoryId = _category?.parentCategoryId;
    _controller = TextEditingController(text: _category?.name ?? '');
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
    MyCategory initialCategory;

    initialCategory = _parentCategoryId != null && _parentCategoryId != ''
        ? _categories?.firstWhere((e) => e.id == _parentCategoryId)
        : _categories.first;

    return AlertDialog(
      title: Text(dialogTitle(_categoryOrSubcategory, newCategory)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _categoryOrSubcategory == CategoryOrSubcategory.category
              ? Container()
              : DropdownButton<MyCategory>(
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
                  onChanged: _onChanged),
          Row(
            children: <Widget>[
              //TODO START HERE - Build a selector, will need a widget to show the icon and be a clickable button to select it - Start with just printing it.
              Expanded(
                flex: 1,
                child: RaisedButton(
                  child: _category?.iconData != null ? Icon(_category?.iconData) : Icon(Icons.error),
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
          showEmojiGrid ? EmojiGrid() : Container(),
        ],
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            //TODO implement delete button , safety check the category isn't being used
            /*FlatButton(
              child: Text('Delete'),
              onPressed: () => {
                widget?.delete,
              },
            ),*/
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
                    widget?.save(_controller.text, _parentCategoryId),
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

  void _onChanged(MyCategory category) {
    setState(() {
      _parentCategoryId = category.id;
    });
  }
}
