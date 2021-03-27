import 'package:flutter/material.dart';

import '../../app/common_widgets/app_button.dart';
import '../../utils/db_consts.dart';
import '../categories_model/app_category/app_category.dart';

class CategoryButton extends StatelessWidget {
  final AppCategory category;
  final Function onPressed;
  final String label;
  final bool filter;
  final bool newEntry;

  const CategoryButton({Key key, this.category, this.onPressed, this.label, this.filter = false, this.newEntry = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = label;

    if (!newEntry || (newEntry && category.id != NO_CATEGORY)) {
      title = category.name;
    }

    return AppButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _leadingWidget(),
          SizedBox(width: 16.0),
          Flexible(child: Text(title)),
          SizedBox(width: 16.0),
          _trailingWidget(),
        ],
      ),
    );
  }

  Widget _leadingWidget() {
    Widget leadingWidget = Container();
    if (!newEntry || (newEntry && category.id != NO_CATEGORY)) {
      leadingWidget = Text(category.emojiChar, textAlign: TextAlign.center, style: TextStyle(fontSize: EMOJI_SIZE));
    }
    return leadingWidget;
  }

  Widget _trailingWidget() {
    if (filter || !newEntry || (newEntry && category.id != NO_CATEGORY)) {
      return Container();
    } else {
      return Icon(Icons.edit_outlined);
    }
  }
}
