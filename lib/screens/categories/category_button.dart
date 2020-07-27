import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final MyCategory category;
  final Function onPressed;
  final String label;

  const CategoryButton({Key key, this.category, this.onPressed, this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed, //TODO navigate to categories page
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(category?.iconData ?? Icons.map),
          SizedBox(width: 30.0),
          Text(category?.name ?? label),
        ],
      ),
    );
  }
}

//TODO refine the button
