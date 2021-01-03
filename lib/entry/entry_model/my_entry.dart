import 'package:equatable/equatable.dart';
import 'package:expenses/entry/entry_model/my_entry_entity.dart';
import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/foundation.dart';

@immutable
class MyEntry extends Equatable with ChangeNotifier {
  MyEntry({
    this.uid,
    this.id,
    this.logId,
    this.currency,
    this.categoryId,
    this.subcategoryId,
    this.amount,
    this.previousAmount,
    this.comment,
    this.dateTime,
    this.tagIDs,
    this.entryMembers = const {},
    this.previousEntryMembers = const {},
  });

  final String uid;
  final String id;
  final String logId;
  final String currency;
  final String categoryId;
  final String subcategoryId;
  final int amount;
  final int previousAmount; //used for changing the total on the log
  final String comment;
  final DateTime dateTime;
  final List<String> tagIDs;
  final Map<String, EntryMember> entryMembers;
  final Map<String, EntryMember> previousEntryMembers; //used for changing individual totals on the log

  MyEntry changeCategories({
    String category,
  }) {
    //safety checks if category has changed and thus nulls the selected subcategory
    String subcategory;
    if (category == this.categoryId) {
      subcategory = this.subcategoryId;
    }

    return MyEntry(
      uid: this.uid,
      id: this.id,
      logId: this.logId,
      currency: this.currency,
      categoryId: category,
      subcategoryId: subcategory,
      amount: this.amount,
      previousAmount: this.previousAmount,
      comment: this.comment,
      dateTime: this.dateTime,
      tagIDs: this.tagIDs,
      entryMembers: this.entryMembers,
      previousEntryMembers: this.previousEntryMembers
    );
  }

  @override
  List<Object> get props =>
      [uid, id, logId, currency, categoryId, subcategoryId, amount, comment, dateTime, tagIDs, entryMembers];

  @override
  String toString() {
    return 'Entry {$UID: $uid, id: $id, $LOG_ID: $logId, '
        'currency: $currency, $CATEGORY: $categoryId, '
        '$SUBCATEGORY: $subcategoryId, $AMOUNT: $amount, previousAmount: $previousAmount, $COMMENT: $comment, '
        '$DATE_TIME: $dateTime, tagIDs: $tagIDs, members: $entryMembers, previousEntryMembers: $previousEntryMembers}';
  }

  MyEntryEntity toEntity() {
    return MyEntryEntity(
      uid: uid,
      id: id,
      logId: logId,
      currency: currency,
      category: categoryId,
      subcategory: subcategoryId,
      amount: amount,
      comment: comment,
      dateTime: dateTime,
      tagIDs: Map<String, String>.fromIterable(tagIDs, key: (e) => e, value: (e) => e),
      entryMembers: entryMembers,
      memberList: entryMembers.keys.toList(),
    );
  }

  static MyEntry fromEntity(MyEntryEntity entity) {
    return MyEntry(
      uid: entity.uid,
      id: entity.id,
      logId: entity.logId,
      currency: entity.currency,
      categoryId: entity.category,
      subcategoryId: entity.subcategory,
      amount: entity.amount,
      comment: entity.comment,
      dateTime: entity.dateTime,
      tagIDs: entity.tagIDs?.entries?.map((e) => e.value)?.toList(),
      entryMembers: entity.entryMembers,
    );
  }

  MyEntry copyWith({
    String uid,
    String id,
    String logId,
    String currency,
    String categoryId,
    String subcategoryId,
    int amount,
    int previousAmount,
    String comment,
    DateTime dateTime,
    List<String> tagIDs,
    Map<String, EntryMember> entryMembers,
    Map<String, EntryMember> previousEntryMembers,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (id == null || identical(id, this.id)) &&
        (logId == null || identical(logId, this.logId)) &&
        (currency == null || identical(currency, this.currency)) &&
        (categoryId == null || identical(categoryId, this.categoryId)) &&
        (subcategoryId == null || identical(subcategoryId, this.subcategoryId)) &&
        (amount == null || identical(amount, this.amount)) &&
        (previousAmount == null || identical(previousAmount, this.previousAmount)) &&
        (comment == null || identical(comment, this.comment)) &&
        (dateTime == null || identical(dateTime, this.dateTime)) &&
        (tagIDs == null || identical(tagIDs, this.tagIDs)) &&
        (entryMembers == null || identical(entryMembers, this.entryMembers)) &&
        (previousEntryMembers == null || identical(previousEntryMembers, this.previousEntryMembers))) {
      return this;
    }

    return new MyEntry(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      logId: logId ?? this.logId,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      amount: amount ?? this.amount,
      previousAmount: previousAmount ?? this.previousAmount,
      comment: comment ?? this.comment,
      dateTime: dateTime ?? this.dateTime,
      tagIDs: tagIDs ?? this.tagIDs,
      entryMembers: entryMembers ?? this.entryMembers,
      previousEntryMembers: previousEntryMembers ?? this.previousEntryMembers,
    );
  }
}
