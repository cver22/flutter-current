import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

class CategoryListTile extends StatelessWidget {
  final MyCategory category;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool heading;

  const CategoryListTile({Key key, @required this.category, this.onTap, this.onLongPress, this.heading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO implement default category system
    //String name;
    /*if(category?.isDefault == true){
      name = '${category.name}' + ' (Default)';
    }else{
      name = category.name;
    }*/
    return ListTile(
      onLongPress: onLongPress,
      leading: category.emojiChar != null
          ? Text(
              category.emojiChar,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: EMOJI_SIZE),
            )
          : Text(
              '\u{2757}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: EMOJI_SIZE),
            ),
      title: Text(heading ? 'Category: ${category.name}' : category.name,
          //Underlines the name if it is a heading
          style: TextStyle(
            decoration: heading ? TextDecoration.underline : TextDecoration.none,
          )),
      //TODO trailing options
      onTap: onTap,
      //TODO add method to edit
    );
  }
}
