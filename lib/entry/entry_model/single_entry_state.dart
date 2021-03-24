import 'dart:collection';

import 'package:equatable/equatable.dart';
import '../../categories/categories_model/app_category/app_category.dart';
import 'app_entry.dart';
import '../../tags/tag_model/tag.dart';
import '../../utils/maybe.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
class SingleEntryState extends Equatable {
  final Maybe<AppEntry> selectedEntry;
  final Maybe<Tag> selectedTag; //new or selected tag being edited
  final Map<String, Tag>
      tags; //collection of all log tags for updating if required
  final List<Tag> searchedTags;
  final List<AppCategory>
      categories; // collection of all log categories for updating if required;
  final List<AppCategory>
      subcategories; //collection of all log subcategories for updating if required;
  final bool processing;
  final bool userUpdated;
  final Maybe<FocusNode> commentFocusNode;
  final Maybe<FocusNode> tagFocusNode;
  final Maybe<String> search;
  final bool canSave;

  SingleEntryState({
    this.selectedTag,
    this.tags,
    this.searchedTags,
    this.selectedEntry,
    this.categories,
    this.subcategories,
    this.processing,
    this.userUpdated,
    this.commentFocusNode,
    this.tagFocusNode,
    this.search,
    this.canSave,
  });

  factory SingleEntryState.initial() {
    return SingleEntryState(
      selectedEntry: Maybe<AppEntry>.none(),
      selectedTag: Maybe<Tag>.none(),
      tags: LinkedHashMap(),
      searchedTags: const [],
      categories: const [],
      subcategories: const [],
      processing: true,
      userUpdated: false,
      commentFocusNode: Maybe<FocusNode>.none(),
      tagFocusNode: Maybe<FocusNode>.none(),
      search: Maybe<String>.none(),
      canSave: false,
    );
  }

  @override
  List<Object> get props => [
        selectedEntry,
        selectedTag,
        tags,
        searchedTags,
        categories,
        subcategories,
        processing,
        userUpdated,
        commentFocusNode,
        tagFocusNode,
        search,
        canSave,
      ];

  @override
  bool get stringify => true;

  SingleEntryState copyWith({
    Maybe<AppEntry> selectedEntry,
    Maybe<Tag> selectedTag,
    Map<String, Tag> tags,
    List<Tag> searchedTags,
    List<AppCategory> categories,
    List<AppCategory> subcategories,
    bool processing,
    bool userUpdated,
    Maybe<FocusNode> commentFocusNode,
    Maybe<FocusNode> tagFocusNode,
    Maybe<String> search,
    bool canSave,
  }) {
    if ((selectedEntry == null ||
            identical(selectedEntry, this.selectedEntry)) &&
        (selectedTag == null || identical(selectedTag, this.selectedTag)) &&
        (tags == null || identical(tags, this.tags)) &&
        (searchedTags == null || identical(searchedTags, this.searchedTags)) &&
        (categories == null || identical(categories, this.categories)) &&
        (subcategories == null ||
            identical(subcategories, this.subcategories)) &&
        (processing == null || identical(processing, this.processing)) &&
        (userUpdated == null || identical(userUpdated, this.userUpdated)) &&
        (commentFocusNode == null ||
            identical(commentFocusNode, this.commentFocusNode)) &&
        (tagFocusNode == null || identical(tagFocusNode, this.tagFocusNode)) &&
        (search == null || identical(search, this.search)) &&
        (canSave == null || identical(canSave, this.canSave))) {
      return this;
    }

    return new SingleEntryState(
      selectedEntry: selectedEntry ?? this.selectedEntry,
      selectedTag: selectedTag ?? this.selectedTag,
      tags: tags ?? this.tags,
      searchedTags: searchedTags ?? this.searchedTags,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      processing: processing ?? this.processing,
      userUpdated: userUpdated ?? this.userUpdated,
      commentFocusNode: commentFocusNode ?? this.commentFocusNode,
      tagFocusNode: tagFocusNode ?? this.tagFocusNode,
      search: search ?? this.search,
      canSave: canSave ?? this.canSave,
    );
  }
}
