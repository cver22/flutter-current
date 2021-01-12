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
  final String initialParent;

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
    this.initialParent,
  }) : super(key: key);

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  CategoryOrSubcategory categoryOrSubcategory;
  MySubcategory subcategory;
  MyCategory category;
  TextEditingController controller;
  String parentCategoryId;
  String name;
  String id;
  List<MyCategory> categories = [];
  bool newCategory;
  bool showEmojiGrid;
  String emojiChar;
  MyCategory selectedCategory;

  //TODO prevent NoCategory and NoSubcategory from being edited or deleted

  void initState() {
    super.initState();
    showEmojiGrid = false;
    categories = widget?.categories;
    categoryOrSubcategory = widget?.categoryOrSubcategory;
    String exclamationMark = '\u{2757}'; // exclamation_mark
    String heavyDollarSign = '\u{1F4B2}'; // heavy_dollar_sign

    if (categoryOrSubcategory == CategoryOrSubcategory.category) {
      category = widget?.category;

      if (category.name != null) {
        newCategory = false;
        emojiChar = category.emojiChar ?? exclamationMark;
        name = category?.name;
        id = category?.id;
      } else {
        newCategory = true;
        showEmojiGrid = true;
        emojiChar = heavyDollarSign;
        name = '';
      }
    } else {
      subcategory = widget?.subcategory;

      if (subcategory.name != null) {
        newCategory = false;
        emojiChar = subcategory.emojiChar ?? exclamationMark;
        name = subcategory?.name;
        id = subcategory?.id;
        parentCategoryId = subcategory?.parentCategoryId;
        if (!categories.any((element) => element.id == parentCategoryId)) {
          parentCategoryId = categories.first.id;
        }
      } else {
        newCategory = true;
        showEmojiGrid = true;
        emojiChar = heavyDollarSign;
        name = '';
        parentCategoryId = widget?.initialParent ?? categories.first.id;
      }
      selectedCategory = categories?.firstWhere((e) => e.id == parentCategoryId);
    }

    controller = TextEditingController(text: name);
    controller.addListener(() {
      final textController = controller.text;
      controller.value = controller.value.copyWith(
        text: textController,
        selection: TextSelection(baseOffset: textController.length, extentOffset: textController.length),
        composing: TextRange.empty,
      );
    });

  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dialogTitle(categoryOrSubcategory, newCategory)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: <Widget>[
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
                child: id == NO_CATEGORY || id == NO_SUBCATEGORY ? Text(name) : TextField(controller: controller, decoration: InputDecoration(border: OutlineInputBorder())),
              ),
            ],
          ),
          _selectParentCategory(selectedCategory),
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
            id == NO_CATEGORY || id == NO_SUBCATEGORY? Container() : FlatButton(
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
                if (controller.text.length > 0)
                  {
                    print('${controller.text}, $emojiChar, $parentCategoryId'),
                    widget?.save(controller.text, emojiChar, parentCategoryId),
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
    return categoryOrSubcategory == CategoryOrSubcategory.category
        ? Container()
        : Row(
            children: [
              Text('Parent Category: '),
              SizedBox(width: 10),
              id == NO_CATEGORY || id == NO_SUBCATEGORY ? Text(initialCategory.name): DropdownButton<MyCategory>(
                  value: initialCategory,
                  items: categories.map((MyCategory category) {
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
      parentCategoryId = category.id;
      selectedCategory = categories?.firstWhere((e) => e.id == parentCategoryId);
    });
  }
}
