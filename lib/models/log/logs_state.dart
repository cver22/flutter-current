import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:flutter/foundation.dart';


//TODO will need a visible method to hide archived/deleted logs

@immutable
class LogsState extends Equatable{
  //map of logId and log
  final Map<String, Log> logs;
  final bool isLoading;
  final Maybe<Log> selectedLog;

  LogsState({
    this.logs,
    this.isLoading,
    this.selectedLog,
  });

  /*Maybe<Log> get selectedLog {
    return selectedLogId.map((logId) => this.logs[logId]);
  }*/

  factory LogsState.initial() {
    return LogsState(
      logs: LinkedHashMap(),
      isLoading: true,
      selectedLog: Maybe.none(),
    );
  }

  LogsState copyWith({
    Map<String, Log> logs,
    bool isLoading,
    Maybe<Log> selectedLog,
  }) {
    return LogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      selectedLog: selectedLog ?? this.selectedLog,
    );
  }

  @override
  List<Object> get props => [logs, isLoading, selectedLog];

  @override
  bool get stringify => true;
}
