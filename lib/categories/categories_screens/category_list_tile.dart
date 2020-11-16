import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

class CategoryListTile extends StatelessWidget {
  final MyCategory category;
  final VoidCallback onTap;
  final VoidCallback onTapEdit;
  final bool heading;

  const CategoryListTile({Key key, @required this.category, this.onTap, this.onTapEdit, this.heading = false})
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
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          heading
              ? Container()
              : Icon(Icons.unfold_more_outlined),
          SizedBox(width: 5),
          category.emojiChar != null
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
        ],
      ),
      title: Text(heading ? 'Category: ${category.name}' : category.name,
          //Underlines the name if it is a heading
          style: TextStyle(
            decoration: heading ? TextDecoration.underline : TextDecoration.none,
          )),
      //TODO trailing options
      trailing: heading
          ? Container(height: 0.0, width: 0.0)
          : Container(
              alignment: AlignmentDirectional.center,
              height: 30.0,
              width: 30.0,
              child: IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(
                  Icons.edit_outlined,
                  size: EMOJI_SIZE,
                ),
                onPressed: onTapEdit,
              ),
            ),
      onTap: onTap,
      //TODO add method to edit
    );
  }
}
