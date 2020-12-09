import 'package:equatable/equatable.dart';
import 'package:expenses/entry/entry_model/my_entry_entity.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/utils/db_consts.dart';

import 'package:flutter/foundation.dart';


@immutable
class MyEntry extends Equatable with ChangeNotifier {
  //TODO entry members map

  MyEntry(
      {this.uid,
        this.id,
      this.logId,
      this.currency,
      this.active = true,
      this.categoryId,
      this.subcategoryId,
      this.amount,
      this.comment,
      this.dateTime,
      this.tagIDs});

  final String uid;
  final String id;
  final String logId;
  final String currency;
  final bool active;
  final String categoryId;
  final String subcategoryId;
  final double amount;
  final String comment;
  final DateTime dateTime;
  final List<String> tagIDs;

  MyEntry copyWith({
    String uid,
    String id,
    String logId,
    String currency,
    bool active,
    String categoryId,
    String subcategoryId,
    double amount,
    String comment,
    DateTime dateTime,
    List<String> tagIDs,
  }) {
    return MyEntry(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      logId: logId ?? this.logId,
      currency: currency ?? this.currency,
      active: active ?? this.active,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      amount: amount ?? this.amount,
      comment: comment ?? this.comment,
      dateTime: dateTime ?? this.dateTime,
      tagIDs: tagIDs ?? this.tagIDs,
    );
  }

  MyEntry changeLog({Log log}) {
    String _logId = this.logId;
    String _category = this.categoryId;
    String _subcategory = this.subcategoryId;
    String _currency = this.currency;
    List<String> _tagIDs = this.tagIDs;

    if (log.id != this.logId) {
      _logId = log.id;
      _currency = log.currency;
      _category = null;
      _subcategory = null;
      _tagIDs = null;
    }

    return MyEntry(
      uid: this.uid,
      id: this.id,
      logId: _logId ?? this.logId,
      currency: _currency ?? this.currency,
      active: this.active,
      categoryId: _category,
      subcategoryId: _subcategory,
      amount: this.amount,
      comment: this.comment,
      dateTime: this.dateTime,
      tagIDs: _tagIDs,
    );
  }

  MyEntry changeCategories({
    String category,
  }) {
    //safety checks if category has changed and thus erases the selected subcategory
    String _subcategory;
    if (category == this.categoryId) {
      _subcategory = this.subcategoryId;
    }

    return MyEntry(
      uid: this.uid,
      id: this.id,
      logId: logId ?? this.logId,
      currency: currency ?? this.currency,
      active: this.active,
      categoryId: category,
      subcategoryId: _subcategory,
      amount: this.amount,
      comment: this.comment,
      dateTime: this.dateTime,
      tagIDs: this.tagIDs,
    );
  }
/*
  MyEntry copyWithSelectedEntryTagList({MyEntry entry}) {
    //makes changes to the entry tag list if changes were made
    //TODO method to remove tag from list
    List<Tag> _selectedEntryTags = Env.store.state.entryState.logTagList;
    
    if (_selectedEntryTags.length > 0) {
      List<String> entryTagIds = [];

      _selectedEntryTags.forEach((addEditTag) {
        if ((entryTagIds.singleWhere((entryTagId) => entryTagId == addEditTag.id, orElse: () => null)) != null) {
          //do nothing, the tag is already in the list
        } else {}
        entryTagIds.add(addEditTag.id);
      });

      return entry.copyWith(tagIDs: entryTagIds);
    } else {
      return entry;
    }
  }*/

  @override
  List<Object> get props => [uid, id, logId, currency, active, categoryId, subcategoryId, amount, comment, dateTime, tagIDs];

  @override
  String toString() {
    return 'Entry {$UID: $uid, id: $id, $LOG_ID: $logId, '
        'currency: $currency, $ACTIVE: $active, $CATEGORY: $categoryId, '
        '$SUBCATEGORY: $subcategoryId, $AMOUNT: $amount, $COMMENT: $comment, '
        '$DATE_TIME: $dateTime, tagIDs: $tagIDs}';
  }

  MyEntryEntity toEntity() {
    return MyEntryEntity(
      uid: uid,
      id: id,
      logId: logId,
      currency: currency,
      active: active,
      category: categoryId,
      subcategory: subcategoryId,
      amount: amount,
      comment: comment,
      dateTime: dateTime,
      tagIDs: Map<String, String>.fromIterable(tagIDs, key: (e) => e, value: (e) => e),
    );
  }

  static MyEntry fromEntity(MyEntryEntity entity) {
    return MyEntry(
      uid: entity.uid,
      id: entity.id,
      logId: entity.logId,
      currency: entity.currency,
      active: entity.active,
      categoryId: entity.category,
      subcategoryId: entity.subcategory,
      amount: entity.amount,
      comment: entity.comment,
      dateTime: entity.dateTime,
      tagIDs: entity.tagIDs?.entries?.map((e) => e.value)?.toList(),
    );
  }
}
