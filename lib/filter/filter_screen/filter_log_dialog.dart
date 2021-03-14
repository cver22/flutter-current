import 'package:expenses/app/common_widgets/app_dialog.dart';
import 'package:expenses/filter/filter_model/filter_state.dart';
import 'package:expenses/filter/filter_screen/filter_list_tile.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/filter_actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class FilterLogDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectState<FilterState>(
        where: notIdentical,
        map: (state) => state.filterState,
        builder: (state) {
          List<String> selectedLogs = state.filter.value.selectedLogs;
          List<Log> allLogs = Env.store.state.logsState.logs.values.toList();

          return AppDialogWithActions(
              title: 'Logs',
              shrinkWrap: true,
              actions: _actions(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: allLogs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String id = allLogs[index].id;
                      return FilterListTile(
                        selected: selectedLogs.contains(id),
                        onSelect: () {
                          Env.store.dispatch(FilterSelectLog(logId: id));
                        },
                        title: allLogs[index].name,
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
        TextButton(
          child: Text('Clear'),
          onPressed: () {
            Env.store.dispatch(FilterClearLogSelection());
          },
        ),
        TextButton(
            child: Text('Done'),
            onPressed: () {
              Get.back();
            }),
      ],
    );
  }
}
