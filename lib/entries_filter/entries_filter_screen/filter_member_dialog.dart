import 'package:expenses/app/common_widgets/app_dialog.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter_state.dart';
import 'package:expenses/entries_filter/entries_filter_screen/filter_list_tile.dart';
import 'package:expenses/store/actions/entries_filter_actions.dart';
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
    return ConnectState<EntriesFilterState>(
        where: notIdentical,
        map: (state) => state.entriesFilterState,
        builder: (state) {
          List<String> allMemberList = state.entriesFilter.value.allMembers.keys.toList();

          return AppDialog(
              child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'Who Paid',
                    //TODO this should change based on entries/chart
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Container(),
                ],
              ),
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
                  itemCount: allMemberList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String id = allMemberList[index];
                    return FilterListTile(
                      selected: paidOrSpent == PaidOrSpent.paid
                          ? state.entriesFilter.value.membersPaid.contains(id)
                          : state.entriesFilter.value.membersSpent.contains(id),
                      onSelect: () {
                        if (paidOrSpent == PaidOrSpent.paid) {
                          Env.store.dispatch(FilterSelectPaid(id: id));
                        } else {
                          Env.store.dispatch(FilterSelectSpent(id: id));
                        }
                      },
                      title: state.entriesFilter.value.allMembers[id],
                    );
                  }),
            ],
          ));
        });
  }
}
