/*
import 'package:equatable/equatable.dart';
import 'package:expenses/models/log/log.dart';

abstract class LogsState extends Equatable {
  const LogsState();

  @override
  List<Object> get props => [];
}

class LogsLoading extends LogsState {}

class LogsLoaded extends LogsState {
  final List<Log> logs;

  const LogsLoaded([this.logs = const []]);

  @override
  List<Object> get props => [logs];

  @override
  String toString() => 'LogsLoadedSuccess { logs: $logs }';
}

class LogsLoadFailure extends LogsState {}
*/
