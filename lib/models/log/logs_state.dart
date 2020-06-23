import 'dart:collection';

import 'package:expenses/models/log/log.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:flutter/foundation.dart';

//TODO equatable or a to string method
//TODO will need a visible method to hide archived/deleted logs

@immutable
class LogsState {
  final Map<String, Log> logs;
  final bool isLoading;
  final Maybe<String> selectedLogId;

  LogsState({
    this.logs,
    this.isLoading,
    this.selectedLogId,
  });

  Maybe<Log> get selectedLog {
    return selectedLogId.map((logId) => this.logs[logId]);
  }

  factory LogsState.initial() {
    return LogsState(
      logs: LinkedHashMap(),
      isLoading: false,
      selectedLogId: Maybe.none(),
    );
  }

  LogsState copyWith({
    Map<String, Log> logs,
    bool isLoading,
    Maybe<String> selectedLogId,
  }) {
    return LogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      selectedLogId: selectedLogId ?? this.selectedLogId,
    );
  }
}
