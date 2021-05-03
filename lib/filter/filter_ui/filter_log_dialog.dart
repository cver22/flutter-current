import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/common_widgets/app_dialog.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../store/actions/filter_actions.dart';
import '../../store/connect_state.dart';
import '../../utils/utils.dart';
import '../filter_model/filter_state.dart';
import 'filter_list_tile.dart';

class FilterLogDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectState<FilterState>(
        where: notIdentical,
        map: (state) => state.filterState,
        builder: (state) {
          List<String?> selectedLogs = state.filter.value.selectedLogs;
          List<Log> allLogs = Env.store.state!.logsState.logs.values.toList();

          return AppDialogWithActions(
              title: 'Logs',
              shrinkWrap: true,
              actions: _actions(),
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
                  }));
        });
  }

  List<Widget> _actions() {
    return [
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
    ];
  }
}
