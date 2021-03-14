import 'package:expenses/app/common_widgets/app_dialog.dart';
import 'package:expenses/filter/filter_model/filter_state.dart';
import 'package:expenses/filter/filter_screen/filter_list_tile.dart';
import 'package:expenses/store/actions/filter_actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class FilterMemberDialog extends StatelessWidget {
  final PaidOrSpent paidOrSpent;

  const FilterMemberDialog({Key key, @required this.paidOrSpent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConnectState<FilterState>(
        where: notIdentical,
        map: (state) => state.filterState,
        builder: (state) {
          List<String> allMemberList = state.allMembers.keys.toList();

          return AppDialogWithActions(
              title: paidOrSpent == PaidOrSpent.paid ? 'Who Paid' : 'Who Spent',
              shrinkWrap: true,
              actions: _actions(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: allMemberList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String id = allMemberList[index];
                      return FilterListTile(
                        selected: paidOrSpent == PaidOrSpent.paid
                            ? state.filter.value.membersPaid.contains(id)
                            : state.filter.value.membersSpent.contains(id),
                        onSelect: () {
                          if (paidOrSpent == PaidOrSpent.paid) {
                            Env.store.dispatch(FilterSelectPaid(id: id));
                          } else {
                            Env.store.dispatch(FilterSelectSpent(id: id));
                          }
                        },
                        title: state.allMembers[id],
                      );
                    }),
              ));
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
                    if (paidOrSpent == PaidOrSpent.paid) {
                      Env.store.dispatch(FilterClearPaidSelection());
                    } else {
                      Env.store.dispatch(FilterClearSpentSelection());
                    }
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
