import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

//leading and trailing components for category list tiles

class CategoryListTileLeading extends StatelessWidget {
  const CategoryListTileLeading({
    Key key,
    @required this.category,
    this.sublist = false,
  }) : super(key: key);

  final MyCategory category;
  final bool sublist;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        sublist
            ? SizedBox(
                width: 10.0,
              )
            : Container(),
        Icon(Icons.unfold_more_outlined),
        SizedBox(width: 5),
        Text(
          category?.emojiChar ?? '\u{2757}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: EMOJI_SIZE),
        ),
      ],
    );
  }
}

class CategoryListTileTrailing extends StatelessWidget {
  const CategoryListTileTrailing({
    Key key,
    @required this.onTapEdit,
  }) : super(key: key);

  final VoidCallback onTapEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
