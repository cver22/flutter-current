import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:expenses/models/entry/my_entry.dart';
import './bloc.dart';

class MyEntryBloc extends Bloc<MyEntryEvent, MyEntryState> {
  @override
  MyEntryState get initialState => LoadEntry();

  @override
  Stream<MyEntryState> mapEventToState(MyEntryEvent event) async* {
    if (event is MyEntryLoaded) {
      yield* _mapEntryLoadedToState(event);
    } else if (event is MyEntryUpdated) {
      yield* _mapEntryUpdatedToState(event);
    }
  }

  _mapEntryLoadedToState(MyEntryLoaded event) {
    MyEntry _entry;

    if(event.myEntry == null){
      _entry.copyWith(dateTime: DateTime.now());
    } else{
      _entry = event.myEntry;
    }

    //TODO how to return the entry

  }

  _mapEntryUpdatedToState(MyEntryUpdated event) {
    //TODO how to return the entry
  }
}
