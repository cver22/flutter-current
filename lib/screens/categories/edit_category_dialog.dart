import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditCategoryDialog extends StatefulWidget {
  final VoidCallback delete;
  final Function(MyCategory) setDefault;
  final Function(String) save;
  final MyCategory category;
  final CategoryOrSubcategory categoryOrSubcategory;

  const EditCategoryDialog(
      {Key key,
      @required this.delete,
      @required this.setDefault,
      @required this.categoryOrSubcategory,
      @required this.save,
      @required this.category})
      : super(key: key);

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  CategoryOrSubcategory _categoryOrSubcategory;
  MyCategory _category;
  TextEditingController _controller;

  void initState() {
    super.initState();
    _categoryOrSubcategory = widget.categoryOrSubcategory;
    _category = widget.category;
    _controller = TextEditingController(text: _category.name);
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

  //TODO ****** Needs some tweaking ******
  //TODO implement setDefault
  //TODO implement a delete feature, safety check the category isn't being used
  //TODO why is dispose not working properly
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_categoryOrSubcategory == CategoryOrSubcategory.category ? 'Edit Category' : 'Edit Subcategory'),
      content: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: _category?.iconData != null ? Icon(_category?.iconData) : Icon(Icons.error),
          ),
          SizedBox(width: 20),
          Expanded(
            flex: 5,
            child: TextField(controller: _controller, decoration: InputDecoration(border: OutlineInputBorder())),
          ),
        ],
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            FlatButton(
              child: Text('Delete'),
              onPressed: () => {
                widget?.delete,
                dispose(),
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => {
                Get.back(),
                dispose(),
              },
            ),
            /*FlatButton(
              child: Text('Set Default'),
              onPressed: () => {
                if (_category.isDefault)
                  {
                    Get.snackbar('${_category.name}', 'is already default'),
                  }
                */ /*else
                  {
                    widget.setDefault(_category),
                    Get.snackbar('${_category.name}', 'set to default'),
                  }*/ /*
              },
            ),*/
            FlatButton(
              child: Text('Save'),
              onPressed: () => {
                widget?.save(_controller.text),
                Get.back(),
                dispose(),

              },
            ),
          ],
        )
      ],
    );
  }
}
