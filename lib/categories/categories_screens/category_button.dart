import 'package:flutter/material.dart';

import '../../app/common_widgets/app_button.dart';
import '../../utils/db_consts.dart';
import '../categories_model/app_category/app_category.dart';

class CategoryButton extends StatelessWidget {
  final AppCategory category;
  final Function onPressed;
  final String label;
  final bool filter;

  const CategoryButton(
      {Key key, this.category, this.onPressed, this.label, this.filter = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _leadingWidget(),
          SizedBox(width: 16.0),
          Flexible(child: Text(category?.name ?? label)),
          SizedBox(width: 16.0),
          _trailingWidget(),
        ],
      ),
    );
  }

  Widget _leadingWidget() {
    Widget leadingWidget = Container();
    if (category?.emojiChar != null) {
      leadingWidget = Text(category.emojiChar,
          textAlign: TextAlign.center, style: TextStyle(fontSize: EMOJI_SIZE));
    }
    return leadingWidget;
  }

  Widget _trailingWidget() {
    if (!filter && category?.emojiChar == null) {
      return Icon(Icons.edit_outlined);
    } else {
      return Container();
    }
  }
}
