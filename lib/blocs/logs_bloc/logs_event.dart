/*
import 'package:equatable/equatable.dart';
import 'package:expenses/models/log/log.dart';

abstract class LogsEvent extends Equatable {
  const LogsEvent();

  @override
  List<Object> get props => [];
}

//tells bloc to load logs from repository
class LoadLogs extends LogsEvent{}

//add new log to list of logs
class LogAdded extends LogsEvent{
  final Log log;

  const LogAdded({this.log});

  @override
  List<Object> get props => [log];

  @override
  String toString() => 'LogAdded { log: $log }';

}

//update an existing log
class LogUpdated extends LogsEvent{
  final Log log;

  const LogUpdated({this.log});

  @override
  List<Object> get props => [log];

  @override
  String toString() => 'LogUpdated { log: $log }';

}

//delete an existing log
class LogDeleted extends LogsEvent{
  final Log log;

  const LogDeleted({this.log});

  @override
  List<Object> get props => [log];

  @override
  String toString() => 'LogDeleted { log: $log }';

}

class LogsUpdated extends LogsEvent{
  final List<Log> logs;

  const LogsUpdated({this.logs});

  @override
  List<Object> get props => [logs];

  @override
  String toString() => 'LogsUpdated { logs: $logs }';

}
*/
