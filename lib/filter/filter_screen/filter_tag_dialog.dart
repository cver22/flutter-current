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
        builder: (state) {
          //TODO build dialog with two tag clouds for selected and other, sorting options, and a search bar
          return AppDialogWithActions(
              title: 'Tags',
              actions: _actions(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TagField(
                      tagFocusNode: FocusNode(),
                      searchOnly: true,
                    ),
                    SizedBox(height: 8.0),
                    _buildSelectedTags(
                      allTags: state.allTags,
                      selectedTagIds: state.filter.value.selectedTags,
                    ),
                    SizedBox(height: 8.0),
                    _buildAllTags(
                        selectedCategories: state.filter.value.selectedCategories,
                        search: state.search,
                        allTags: state.allTags,
                        searchedTags: state.searchedTags,
                        selectedTagNames: state.filter.value.selectedTags),
                  ],
                ),
              ));
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

    return TagCollection(
      tags: collectionTags,
      collectionName: 'Selected Tags',
      chipsEditable: false,
      search: Maybe.none(),
      filterSelect: true,
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

    return SingleChildScrollView(
      child: TagCollection(
        tags: collectionTags,
        collectionName: search.isNone ? 'Tags by Frequency' : 'Searched Tags',
        search: search,
        chipsEditable: false,
        filterSelect: true,
      ),
    );
  }
}
