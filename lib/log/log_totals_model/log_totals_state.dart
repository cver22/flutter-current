import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'log_total.dart';

@immutable
class LogTotalsState extends Equatable {
  final Map<String, LogTotal> logTotals;

  LogTotalsState({required this.logTotals});

  @override
  List<Object> get props => [logTotals];

  factory LogTotalsState.initial() {
    return LogTotalsState(
      logTotals: LinkedHashMap(),
    );
  }

  @override
  bool get stringify => true;

  LogTotalsState copyWith({
    Map<String, LogTotal>? logTotals,
  }) {
    if ((logTotals == null || identical(logTotals, this.logTotals))) {
      return this;
    }

    return new LogTotalsState(
      logTotals: logTotals ?? this.logTotals,
    );
  }
}
