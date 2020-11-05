import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final MyCategory category;
  final Function onPressed;
  final String label;

  const CategoryButton({Key key, this.category, this.onPressed, this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          category?.emojiChar != null
              ? Text(
                  category.emojiChar,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: EMOJI_SIZE),
                )
              : Icon(Icons.edit_outlined),

          SizedBox(width: 10.0),
          Text(category?.name ?? label),
        ],
      ),
    );
  }
}

//TODO refine the button
