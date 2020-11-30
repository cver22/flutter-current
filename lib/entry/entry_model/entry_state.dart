import 'package:equatable/equatable.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';

@immutable
class EntryState extends Equatable {

  final Maybe<MyEntry> selectedEntry;
  final Maybe<Tag> selectedTag; //new or selected tag being edited
  final List<Tag> logTagList; //collection of all new tags in this entry
  final bool savingEntry;

  EntryState({this.selectedTag, this.logTagList, this.selectedEntry, this.savingEntry});

  factory EntryState.initial() {
    return EntryState(

      selectedEntry: Maybe.none(),
      selectedTag: Maybe.none(),
      logTagList: [],
      savingEntry: false,

    );
  }

  EntryState copyWith({

    Maybe<MyEntry> selectedEntry,
    Maybe<Tag> selectedTag,
    List<Tag> logTagList,
    bool savingEntry,

  }) {
    return EntryState(

      selectedEntry: selectedEntry ?? this.selectedEntry,
      selectedTag: selectedTag ?? this.selectedTag,
      logTagList: logTagList ?? this.logTagList,
      savingEntry: savingEntry ?? this.savingEntry,
    );
  }

  @override
  List<Object> get props => [selectedEntry, selectedTag, logTagList, savingEntry];

  @override
  bool get stringify => true;

}