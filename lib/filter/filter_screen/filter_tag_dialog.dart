import 'package:expenses/app/common_widgets/app_dialog.dart';
import 'package:expenses/filter/filter_model/filter_state.dart';
import 'package:expenses/store/actions/filter_actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class FilterTagDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectState<FilterState>(
        where: notIdentical,
        map: (state) => state.filterState,
        builder: (state) {

          //TODO build dialog with two tag clouds for selected and other, sorting options, and a search bar
          return AppDialogWithActions(
              title: 'Logs',
              shrinkWrap: true,
              actions: _actions(),
              child: Container());
        });
  }

  Row _actions() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FlatButton(
          child: Text('Clear'),
          onPressed: () {
            Env.store.dispatch(FilterClearTagSelection());
          },
        ),
        FlatButton(
            child: Text('Done'),
            onPressed: () {
              Get.back();
            }),
      ],
    );
  }
}
