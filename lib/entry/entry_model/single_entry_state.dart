import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/my_category/app_category.dart';
import 'package:expenses/entry/entry_model/app_entry.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

@immutable
class SingleEntryState extends Equatable {
  final Maybe<MyEntry> selectedEntry;
  final Maybe<Tag> selectedTag; //new or selected tag being edited
  final Map<String, Tag> tags; //collection of all log tags for updating if required
  final List<AppCategory> categories; // collection of all log categories for updating if required;
  final List<AppCategory> subcategories; //collection of all log subcategories for updating if required;
  final bool processing;
  final bool userUpdated;
  final Maybe<FocusNode> commentFocusNode;
  final Maybe<FocusNode> tagFocusNode;

  SingleEntryState({
    this.selectedTag,
    this.tags,
    this.selectedEntry,
    this.categories,
    this.subcategories,
    this.processing,
    this.userUpdated,
    this.commentFocusNode,
    this.tagFocusNode,
  });

  factory SingleEntryState.initial() {
    return SingleEntryState(
      selectedEntry: Maybe.none(),
      selectedTag: Maybe.none(),
      tags: LinkedHashMap(),
      categories: List<AppCategory>(),
      subcategories: List<AppCategory>(),
      processing: true,
      userUpdated: false,
      commentFocusNode: Maybe.none(),
      tagFocusNode: Maybe.none(),
    );
  }

  @override
  List<Object> get props => [
        selectedEntry,
        selectedTag,
        tags,
        categories,
        subcategories,
        processing,
        userUpdated,
        commentFocusNode,
        tagFocusNode
      ];

  @override
  bool get stringify => true;

  SingleEntryState copyWith({
    Maybe<MyEntry> selectedEntry,
    Maybe<Tag> selectedTag,
    Map<String, Tag> tags,
    List<AppCategory> categories,
    List<AppCategory> subcategories,
    bool processing,
    bool userUpdated,
    Maybe<FocusNode> commentFocusNode,
    Maybe<FocusNode> tagFocusNode,
  }) {
    if ((selectedEntry == null || identical(selectedEntry, this.selectedEntry)) &&
        (selectedTag == null || identical(selectedTag, this.selectedTag)) &&
        (tags == null || identical(tags, this.tags)) &&
        (categories == null || identical(categories, this.categories)) &&
        (subcategories == null || identical(subcategories, this.subcategories)) &&
        (processing == null || identical(processing, this.processing)) &&
        (userUpdated == null ||
            identical(
                userUpdated,
                this.userUpdated &&
                    (commentFocusNode == null || identical(commentFocusNode, this.commentFocusNode)) &&
                    (tagFocusNode == null || identical(tagFocusNode, this.tagFocusNode))))) {
      return this;
    }

    return new SingleEntryState(
      selectedEntry: selectedEntry ?? this.selectedEntry,
      selectedTag: selectedTag ?? this.selectedTag,
      tags: tags ?? this.tags,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      processing: processing ?? this.processing,
      userUpdated: userUpdated ?? this.userUpdated,
      commentFocusNode: commentFocusNode ?? this.commentFocusNode,
      tagFocusNode: tagFocusNode ?? this.tagFocusNode,
    );
  }
}
