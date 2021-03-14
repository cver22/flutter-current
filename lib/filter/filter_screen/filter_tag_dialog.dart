import 'package:expenses/app/common_widgets/app_dialog.dart';
import 'package:expenses/filter/filter_model/filter_state.dart';
import 'package:expenses/store/actions/filter_actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/tag_collection.dart';
import 'package:expenses/tags/tags_ui/tag_field.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

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
            actions: _actions(),
            child: Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: TagField(
                        tagFocusNode: FocusNode(),
                        searchOnly: true,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text('Selected Tags'),
                    Expanded(
                      flex: filterState.filter.value.selectedTags.isNotEmpty ? (filterState.filter.value.selectedTags.length/3).ceil() : 0,
                      child: _buildSelectedTags(
                        allTags: filterState.allTags,
                        selectedTagIds: filterState.filter.value.selectedTags,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(filterState.search.isNone ? 'Tags by Frequency' : 'Searched Tags'),
                    Expanded(
                      flex: 4,
                      child: _buildAllTags(
                          selectedCategories: filterState.filter.value.selectedCategories,
                          search: filterState.search,
                          allTags: filterState.allTags,
                          searchedTags: filterState.searchedTags,
                          selectedTagNames: filterState.filter.value.selectedTags),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Row _actions() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FlatButton(
          child: Text('Clear'),
          onPressed: () {
            Env.store.dispatch(FilterClearTagSelection());
          },
        ),
        FlatButton(
            child: Text('Done'),
            onPressed: () {
              Get.back();
            }),
      ],
    );
  }

  Widget _buildSelectedTags({
    @required List<Tag> allTags,
    @required List<String> selectedTagIds,
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

    return SingleChildScrollView(
      child: TagCollection(
        tags: collectionTags,
        chipsEditable: false,
        search: Maybe.none(),
        filterSelect: true,
      ),
    );
  }

  Widget _buildAllTags({
    @required Maybe<String> search,
    @required List<Tag> allTags,
    @required List<String> selectedTagNames,
    @required List<Tag> searchedTags,
    @required List<String> selectedCategories,
  }) {
    List<Tag> collectionTags = search.isNone ? List.from(allTags) : List.from(searchedTags);

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
    if (search.isNone || search.isSome && collectionTags.length > 1) {
      return SingleChildScrollView(
        child: TagCollection(
          tags: collectionTags,
          search: search,
          chipsEditable: false,
          filterSelect: true,
        ),
      );
    } else {
      return Text('No search results');
    }
  }
}
