import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';

@immutable
class SingleEntryState extends Equatable {

  final Maybe<MyEntry> selectedEntry;
  final Maybe<Tag> selectedTag; //new or selected tag being edited
  final List<Tag> logTagList; //collection of all log tags for updating
  final List<MyCategory> logCategoryList; // collection of all log categories for updating;
  final bool savingEntry;

  SingleEntryState( {this.selectedTag, this.logTagList, this.selectedEntry, this.logCategoryList, this.savingEntry});

  factory SingleEntryState.initial() {
    return SingleEntryState(

      selectedEntry: Maybe.none(),
      selectedTag: Maybe.none(),
      logTagList: [],
      logCategoryList: [],
      savingEntry: false,

    );
  }

  SingleEntryState copyWith({

    Maybe<MyEntry> selectedEntry,
    Maybe<Tag> selectedTag,
    List<Tag> logTagList,
    List<MyCategory> logCategoryList,
    bool savingEntry,

  }) {
    return SingleEntryState(

      selectedEntry: selectedEntry ?? this.selectedEntry,
      selectedTag: selectedTag ?? this.selectedTag,
      logTagList: logTagList ?? this.logTagList,
      logCategoryList: logCategoryList ?? this.logCategoryList,
      savingEntry: savingEntry ?? this.savingEntry,
    );
  }

  @override
  List<Object> get props => [selectedEntry, selectedTag, logTagList, logCategoryList, savingEntry];

  @override
  bool get stringify => true;

}