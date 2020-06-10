import 'package:equatable/equatable.dart';
import 'package:expenses/models/entry/my_entry.dart';

abstract class MyEntryState extends Equatable {
  const MyEntryState();

  @override
  List<Object> get props => [];
}

class MyEntryLoading extends MyEntryState {}

class MyEntryLoaded extends MyEntryState {
  final MyEntry myEntry;

  const MyEntryLoaded([this.myEntry]);

  @override
  List<Object> get props => [myEntry];

  @override
  String toString() => 'MyEntryLoadedSuccess { myEntry: $myEntry }';
}

class MyEntryLoadFailure extends MyEntryState {}
