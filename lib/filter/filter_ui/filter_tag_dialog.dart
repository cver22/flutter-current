import 'package:expenses/filter/filter_ui/filter_actions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/common_widgets/app_dialog.dart';
import '../../env.dart';
import '../../store/actions/filter_actions.dart';
import '../../store/connect_state.dart';
import '../../tags/tag_model/tag.dart';
import '../../tags/tags_ui/tag_collection.dart';
import '../../tags/tags_ui/tag_field.dart';
import '../../utils/maybe.dart';
import '../../utils/utils.dart';
import '../filter_model/filter_state.dart';

class FilterTagDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectState<FilterState>(
        where: notIdentical,
        map: (state) => state.filterState,
        builder: (filterState) {
          //TODO build dialog with two tag clouds for selected and other, sorting options, and a search bar
          return AppDialogWithActions(
            title: 'Tags',
            topWidget: TagField(
              tagFocusNode: FocusNode(),
              searchOnly: true,
            ),
            actions: filterActions(onPressedClear: () {
              Env.store.dispatch(FilterClearTagSelection());
            },),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  filterState.tagSearch.isSome
                      ? Text('Searched Tags')
                      : Container(),
                  filterState.tagSearch.isSome
                      ? _buildAllTags(
                          selectedCategories:
                              filterState.filter.value.selectedCategories,
                          search: filterState.tagSearch,
                          allTags: filterState.allTags,
                          searchedTags: filterState.searchedTags,
                          selectedTagNames:
                              filterState.filter.value.selectedTags)
                      : Container(),
                  Text('Selected Tags'),
                  _buildSelectedTags(
                    allTags: filterState.allTags,
                    selectedTagIds: filterState.filter.value.selectedTags,
                  ),
                  SizedBox(height: 8.0),
                  filterState.tagSearch.isNone
                      ? Text('Tags by Frequency')
                      : Container(),
                  filterState.tagSearch.isNone
                      ? _buildAllTags(
                          selectedCategories:
                              filterState.filter.value.selectedCategories,
                          search: filterState.tagSearch,
                          allTags: filterState.allTags,
                          searchedTags: filterState.searchedTags,
                          selectedTagNames:
                              filterState.filter.value.selectedTags)
                      : Container(),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildSelectedTags({
    required List<Tag> allTags,
    required List<String?> selectedTagIds,
  }) {
    List<Tag> collectionTags = List.from(allTags);

    //retain only selected tags
    collectionTags.retainWhere((tag) {
      bool retain = false;
      selectedTagIds.forEach((selectedTagName) {
        if (selectedTagName == tag.name) {
          retain = true;
        }
      });

      return retain;
    });

    return TagCollection(
      tags: collectionTags,
      chipsEditable: false,
      search: Maybe.none(),
      filterSelect: true,
    );
  }

  Widget _buildAllTags({
    required Maybe<String> search,
    required List<Tag> allTags,
    required List<String?> selectedTagNames,
    required List<Tag> searchedTags,
    required List<String> selectedCategories,
  }) {
    List<Tag> collectionTags =
        search.isNone ? List.from(allTags) : List.from(searchedTags);

    //remove any selected tags from this collection
    collectionTags.removeWhere((tag) {
      bool remove = false;
      selectedTagNames.forEach((selectedTagId) {
        if (selectedTagId == tag.name) {
          remove = true;
        }
      });

      return remove;
    });

    //if a category is selected, only display tags found in that category
    if (selectedCategories.isNotEmpty) {
      collectionTags.removeWhere((tag) {
        bool remove = true;
        tag.tagCategoryFrequency.forEach((categoryName, value) {
          if (selectedCategories.contains(categoryName)) {
            remove = false;
          }
        });

        return remove;
      });
    }
    if (search.isNone || search.isSome && collectionTags.length > 0) {
      return TagCollection(
        tags: collectionTags,
        search: search,
        chipsEditable: false,
        filterSelect: true,
      );
    } else {
      return Text('No search results');
    }
  }
}
