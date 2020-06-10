import 'package:equatable/equatable.dart';
import 'package:expenses/models/entry/my_entry.dart';

abstract class MyEntryEvent extends Equatable {
  const MyEntryEvent();

  @override
  List<Object> get props => [];
}

class MyEntryLoaded extends MyEntryEvent {}

class MyEntryUpdated extends MyEntryEvent{
  final MyEntry myEntry;

  const MyEntryUpdated({this.myEntry});

  @override
  List<Object> get props => [myEntry];

  @override
  String toString() => 'MyEntryUpdated { myEntry: $myEntry }';

}


