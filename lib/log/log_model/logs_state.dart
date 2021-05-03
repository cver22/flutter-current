import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'log.dart';
import '../../utils/maybe.dart';
import 'package:flutter/foundation.dart';

//TODO will need a visible method to hide archived/deleted logs

@immutable
class LogsState extends Equatable {
  final Map<String, Log> logs; // id, log
  final bool isLoading;
  final Maybe<Log> selectedLog;
  final List<bool> expandedCategories;
  final bool userUpdated;
  final bool canSave;

  LogsState(
      {required this.logs,
      required this.isLoading,
      required this.selectedLog,
      required this.expandedCategories,
      required this.userUpdated,
      required this.canSave});

  factory LogsState.initial() {
    return LogsState(
      logs: LinkedHashMap(),
      isLoading: true,
      selectedLog: Maybe<Log>.none(),
      expandedCategories: const [],
      userUpdated: false,
      canSave: false,
    );
  }

  @override
  List<Object> get props => [
        logs,
        isLoading,
        selectedLog,
        expandedCategories,
        userUpdated,
        canSave
      ];

  @override
  bool get stringify => true;

  LogsState copyWith({
    Map<String, Log>? logs,
    bool? isLoading,
    Maybe<Log>? selectedLog,
    List<bool>? expandedCategories,
    bool? userUpdated,
    bool? canSave,
  }) {
    if ((logs == null || identical(logs, this.logs)) &&
        (isLoading == null || identical(isLoading, this.isLoading)) &&
        (selectedLog == null || identical(selectedLog, this.selectedLog)) &&
        (expandedCategories == null ||
            identical(expandedCategories, this.expandedCategories)) &&
        (userUpdated == null || identical(userUpdated, this.userUpdated)) &&
        (canSave == null || identical(canSave, this.canSave))) {
      return this;
    }

    return new LogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      selectedLog: selectedLog ?? this.selectedLog,
      expandedCategories: expandedCategories ?? this.expandedCategories,
      userUpdated: userUpdated ?? this.userUpdated,
      canSave: canSave ?? this.canSave,
    );
  }
}
