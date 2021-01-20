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
  final Map<String, Tag> tags; //collection of all log tags for updating if required
  final List<MyCategory> categories; // collection of all log categories for updating if required;
  final List<MyCategory> subcategories; //collection of all log subcategories for updating if required;
  final bool savingEntry;

  SingleEntryState( {this.selectedTag, this.tags, this.selectedEntry, this.categories, this.subcategories, this.savingEntry});

  factory SingleEntryState.initial() {
    return SingleEntryState(

      selectedEntry: Maybe.none(),
      selectedTag: Maybe.none(),
      tags: LinkedHashMap(),
      categories: List<MyCategory>(),
      subcategories: List<MyCategory>(),
      savingEntry: false,

    );
  }

  @override
  List<Object> get props => [selectedEntry, selectedTag, tags, categories, subcategories, savingEntry];

  @override
  bool get stringify => true;

  SingleEntryState copyWith({
    Maybe<MyEntry> selectedEntry,
    Maybe<Tag> selectedTag,
    Map<String, Tag> tags,
    List<MyCategory> categories,
    List<MyCategory> subcategories,
    bool savingEntry,
  }) {
    if ((selectedEntry == null || identical(selectedEntry, this.selectedEntry)) &&
        (selectedTag == null || identical(selectedTag, this.selectedTag)) &&
        (tags == null || identical(tags, this.tags)) &&
        (categories == null || identical(categories, this.categories)) &&
        (subcategories == null || identical(subcategories, this.subcategories)) &&
        (savingEntry == null || identical(savingEntry, this.savingEntry))) {
      return this;
    }

    return new SingleEntryState(
      selectedEntry: selectedEntry ?? this.selectedEntry,
      selectedTag: selectedTag ?? this.selectedTag,
      tags: tags ?? this.tags,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      savingEntry: savingEntry ?? this.savingEntry,
    );
  }
}