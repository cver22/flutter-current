import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/common_widgets/app_button.dart';
import '../../app/common_widgets/app_dialog.dart';
import '../../utils/db_consts.dart';
import '../categories_model/app_category/app_category.dart';


class EditCategoryDialog extends StatefulWidget {
  final VoidCallback delete;
  final Function(AppCategory) setDefault;
  final Function(String, String, String)
      save; //Category (name, emojiChar, parentCategoryId)
  final AppCategory category;
  final String initialParent;

  //TODO I can likely simplify the category and subcategory system where all parent categories have no parent ID, only subcategories do
  final CategoryOrSubcategory categoryOrSubcategory;
  final List<AppCategory> categories;

  const EditCategoryDialog({
    Key key,
    this.delete,
    this.setDefault,
    @required this.categoryOrSubcategory,
    @required this.save,
    this.category,
    this.categories,
    this.initialParent,
  }) : super(key: key);

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  CategoryOrSubcategory categoryOrSubcategory;
  AppCategory subcategory;
  AppCategory category;
  TextEditingController controller;
  String parentCategoryId;
  String name;
  String id;
  List<AppCategory> categories = [];
  bool newCategory;
  bool showEmojiGrid;
  String emojiChar;
  AppCategory selectedCategory;
  bool canSave;
  bool notModifiable;

  //TODO prevent NoCategory and NoSubcategory from being edited or deleted

  void initState() {
    super.initState();
    showEmojiGrid = false;
    categories = widget?.categories;
    categoryOrSubcategory = widget?.categoryOrSubcategory;
    String exclamationMark = '\u{2757}'; // exclamation_mark
    String heavyDollarSign = '\u{1F4B2}'; // heavy_dollar_sign
    category = widget?.category;
    if (category.id != null) {
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

    if (categoryOrSubcategory == CategoryOrSubcategory.subcategory) {
      if (newCategory) {
        parentCategoryId = widget?.initialParent ?? NO_CATEGORY;
      } else {
        parentCategoryId = category?.parentCategoryId ?? NO_CATEGORY;
      }

      selectedCategory =
          categories?.firstWhere((e) => e.id == parentCategoryId);
    }

    controller = TextEditingController(text: name);
    canSave = controller.text != null && controller.value.text.length > 0;

    notModifiable = _notModifiable(categoryId: id);
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogWithActions(
      title: dialogTitle(categoryOrSubcategory, newCategory),
      topWidget: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: <Widget>[
                _buildEmojiButton(),
                SizedBox(width: 20),
                _buildNameField(),
              ],
            ),
            categoryOrSubcategory == CategoryOrSubcategory.category
                ? Container()
                : _selectParentCategory(selectedCategory),
          ],
        ),
      ),
      shrinkWrap: true,
      child: showEmojiGrid
          ? _emojiPicker() /*EmojiPicker(
              emojiSelection: (emoji) => {
                    setState(() {
                      emojiChar = emoji;
                    })
                  })*/
          : Container(
              height: 0.0,
            ),
      actions: <Widget>[
        _canDelete(categoryId: category.id)
            ? TextButton(child: Text('Delete'), onPressed: widget.delete)
            : Container(),

        TextButton(
          child: Text('Cancel'),
          onPressed: () => {
            Get.back(),
          },
        ),

        //TODO implement default category system, option to turn it on
        /*TextButton(
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
        TextButton(
          child: Text('Save'),
          onPressed: canSave
              ? () => {
                    //TODO more conditions based on category or subcategory && _category.parentCategoryId != null, _controller.text != _category.name

                    widget?.save(controller.text, emojiChar, parentCategoryId),
                    Get.back(),
                  }
              : null,
        ),
      ],
    );
  }

  Expanded _buildNameField() {
    return Expanded(
      flex: 5,
      child: notModifiable
          ? Text(name)
          : TextField(
              controller: controller,
              decoration: InputDecoration(border: OutlineInputBorder()),
              onChanged: (value) {
                setState(() {
                  canSave = value != null && value.length > 0;
                });
              },
            ),
    );
  }

  Expanded _buildEmojiButton() {
    return Expanded(
      flex: 1,
      child: AppButton(
        child: Text(
          emojiChar,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22),
        ),
        onPressed: () => setState(() {
          showEmojiGrid = true;
        }),
      ),
    );
  }

  Widget _selectParentCategory(AppCategory initialCategory) {
    List<AppCategory> selectableCategories = List.from(categories);
    selectableCategories.removeWhere(
        (element) => element.id == NO_CATEGORY || element.id == TRANSFER_FUNDS);

    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Text(
            'Parent Category: ',
            maxLines: 2,
          ),
        ),
        SizedBox(width: 10),
        notModifiable
            ? Text(initialCategory.name)
            : Expanded(
                flex: 2,
                child: DropdownButton<AppCategory>(
                    isExpanded: true,
                    value: initialCategory,
                    items: selectableCategories.map((AppCategory category) {
                      return DropdownMenuItem<AppCategory>(
                        value: category,
                        child: Text(
                          category.name,
                          overflow: TextOverflow.visible,
                          maxLines: 2,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: _onParentCategoryChanged),
              ),
      ],
    );
  }

  String dialogTitle(
      CategoryOrSubcategory _categoryOrSubcategory, bool newCategory) {
    if (_categoryOrSubcategory == CategoryOrSubcategory.category) {
      if (newCategory) return 'New Category';
      return 'Edit Category';
    } else {
      if (newCategory) return 'New Subcategory';
      return 'Edit Subcategory';
    }
  }

  void _onParentCategoryChanged(AppCategory category) {
    setState(() {
      parentCategoryId = category.id;
      selectedCategory =
          categories?.firstWhere((e) => e.id == parentCategoryId);
    });
  }

  bool _canDelete({String categoryId}) {
    if (categoryId == null ||
        categoryId == NO_CATEGORY ||
        categoryId.contains(OTHER) ||
        categoryId == TRANSFER_FUNDS) {
      return false;
    }
    return true;
  }

  bool _notModifiable({String categoryId}) {
    //catch null as modifiable
    if (categoryId == null) {
      return false;
    }

    //special categories and subcategories can not be renamed
    return categoryId == NO_CATEGORY ||
        categoryId.contains(OTHER) ||
        categoryId == TRANSFER_FUNDS;
  }

  Widget _emojiPicker() {

    //TODO adda border around this

    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        setState(() {
          emojiChar = emoji.emoji;
        });
      },
      config: Config(
          columns: 7,
          emojiSizeMax: 24.0,
          verticalSpacing: 0,
          horizontalSpacing: 0,
          initCategory: Category.OBJECTS,
          bgColor: Colors.white,
          indicatorColor: Colors.blue,
          iconColor: Colors.grey,
          iconColorSelected: Colors.blue,
          progressIndicatorColor: Colors.blue,
          showRecentsTab: false,
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.MATERIAL
      ),
    );

  }
}
