import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:flutter/foundation.dart';


//TODO will need a visible method to hide archived/deleted logs

@immutable
class LogsState extends Equatable{
  //map of logId and log
  final Map<String, Log> logs;
  final bool isLoading;
  final Maybe<Log> selectedLog;
  final List<bool> expandedCategories;

  LogsState({
    this.logs,
    this.isLoading,
    this.selectedLog,
    this.expandedCategories
  });

  /*Maybe<Log> get selectedLog {
    return selectedLogId.map((logId) => this.logs[logId]);
  }*/

  factory LogsState.initial() {
    return LogsState(
      logs: LinkedHashMap(),
      isLoading: true,
      selectedLog: Maybe.none(),
      expandedCategories: List(),
    );
  }

  @override
  List<Object> get props => [logs, isLoading, selectedLog, expandedCategories];

  @override
  bool get stringify => true;

  LogsState copyWith({
    Map<String, Log> logs,
    bool isLoading,
    Maybe<Log> selectedLog,
    List<bool> expandedCategories,
  }) {
    if ((logs == null || identical(logs, this.logs)) &&
        (isLoading == null || identical(isLoading, this.isLoading)) &&
        (selectedLog == null || identical(selectedLog, this.selectedLog)) &&
        (expandedCategories == null || identical(expandedCategories, this.expandedCategories))) {
      return this;
    }

    return new LogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      selectedLog: selectedLog ?? this.selectedLog,
      expandedCategories: expandedCategories ?? this.expandedCategories,
    );
  }
}
