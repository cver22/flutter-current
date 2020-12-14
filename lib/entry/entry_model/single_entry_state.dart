import 'dart:collection';

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
  final Map<String, Tag> tags; //collection of all log tags for updating
  final List<MyCategory> logCategoryList; // collection of all log categories for updating;
  final bool savingEntry;

  SingleEntryState( {this.selectedTag, this.tags, this.selectedEntry, this.logCategoryList, this.savingEntry});

  factory SingleEntryState.initial() {
    return SingleEntryState(

      selectedEntry: Maybe.none(),
      selectedTag: Maybe.none(),
      tags: LinkedHashMap(),
      logCategoryList: List<MyCategory>(),
      savingEntry: false,

    );
  }

  SingleEntryState copyWith({

    Maybe<MyEntry> selectedEntry,
    Maybe<Tag> selectedTag,
    Map<String, Tag> tags,
    List<MyCategory> logCategoryList,
    bool savingEntry,

  }) {

    return SingleEntryState(

      selectedEntry: selectedEntry ?? this.selectedEntry,
      selectedTag: selectedTag ?? this.selectedTag,
      tags: tags ?? this.tags,
      logCategoryList: logCategoryList ?? this.logCategoryList,
      savingEntry: savingEntry ?? this.savingEntry,
    );
  }

  @override
  List<Object> get props => [selectedEntry, selectedTag, tags, logCategoryList, savingEntry];

  @override
  bool get stringify => true;

}