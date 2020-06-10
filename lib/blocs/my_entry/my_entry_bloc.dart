import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class MyEntryBloc extends Bloc<MyEntryEvent, MyEntryState> {
  @override
  MyEntryState get initialState => InitialMyEntryState();

  @override
  Stream<MyEntryState> mapEventToState(
    MyEntryEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
