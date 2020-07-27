import 'package:expenses/env.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/categories/category_list_tile.dart';
import 'package:expenses/store/actions/actions.dart';

import 'package:flutter/material.dart';

class SubcategoryListDialog extends StatelessWidget {
  final VoidCallback backChevron;

  SubcategoryListDialog({Key key, this.backChevron}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Log _log = Env.store.state.logsState
        .logs[Env.store.state.entriesState.selectedEntry.value.logId];
    List<MySubcategory> _subcategories = _log.subcategories
        .where((element) =>
            element.parentCategoryId ==
            Env.store.state.entriesState.selectedEntry.value.category)
        .toList();

    return Dialog(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      //TODO move to constant
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: backChevron,
              ),
              Text(
                'Subcategory',
                style: TextStyle(fontSize: 20.0),
              ),
              FlatButton(
                child: Text('Skip'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          ListView(
              shrinkWrap: true,
              //TODO implement onReorder
              children: _subcategories
                  .map((MySubcategory subcategory) => CategoryListTile(
                      category: subcategory,
                      onTap: () {
                        Env.store.dispatch(
                            UpdateSelectedEntry(subcategory: subcategory.id));
                        Navigator.of(context).pop();
                      }))
                  .toList()),
        ],
      ),
    );
  }
}
