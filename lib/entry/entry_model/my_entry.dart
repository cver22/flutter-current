
import 'package:equatable/equatable.dart';
import 'package:expenses/entry/entry_model/my_entry_entity.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/foundation.dart';

@immutable
class MyEntry extends Equatable with ChangeNotifier {

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
      this.tagIDs,
      this.entryMembers = const {}});

  final String uid;
  final String id;
  final String logId;
  final String currency;
  final bool active;
  final String categoryId;
  final String subcategoryId;
  final int amount;
  final String comment;
  final DateTime dateTime;
  final List<String> tagIDs;
  final Map<String, EntryMember> entryMembers;

  MyEntry changeLog({Log log}) {
    String logId = this.logId;
    String category = this.categoryId;
    String subcategory = this.subcategoryId;
    String currency = this.currency;
    List<String> tagIDs = this.tagIDs;
    Map<String, EntryMember> entryMembers = this.entryMembers;

    if (log.id != this.logId) {
      logId = log.id;
      currency = log.currency;
      category = null;
      subcategory = null;
      tagIDs = null;
      entryMembers.clear();

    }

    return MyEntry(
      uid: this.uid,
      id: this.id,
      logId: logId ?? this.logId,
      currency: currency ?? this.currency,
      active: this.active,
      categoryId: category,
      subcategoryId: subcategory,
      amount: this.amount,
      comment: this.comment,
      dateTime: this.dateTime,
      tagIDs: tagIDs,
      entryMembers: entryMembers
    );
  }

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
      active: this.active,
      categoryId: category,
      subcategoryId: subcategory,
      amount: this.amount,
      comment: this.comment,
      dateTime: this.dateTime,
      tagIDs: this.tagIDs,
      entryMembers: this.entryMembers,
    );
  }

  @override
  List<Object> get props => [uid, id, logId, currency, active, categoryId, subcategoryId, amount, comment, dateTime, tagIDs, entryMembers];

  @override
  String toString() {
    return 'Entry {$UID: $uid, id: $id, $LOG_ID: $logId, '
        'currency: $currency, $ACTIVE: $active, $CATEGORY: $categoryId, '
        '$SUBCATEGORY: $subcategoryId, $AMOUNT: $amount, $COMMENT: $comment, '
        '$DATE_TIME: $dateTime, tagIDs: $tagIDs, members: $entryMembers}';
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
      entryMembers: entryMembers,
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
      entryMembers: entity.entryMembers,
    );
  }

  MyEntry copyWith({
    String uid,
    String id,
    String logId,
    String currency,
    bool active,
    String categoryId,
    String subcategoryId,
    int amount,
    String comment,
    DateTime dateTime,
    List<String> tagIDs,
    Map<String, EntryMember> entryMembers,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (id == null || identical(id, this.id)) &&
        (logId == null || identical(logId, this.logId)) &&
        (currency == null || identical(currency, this.currency)) &&
        (active == null || identical(active, this.active)) &&
        (categoryId == null || identical(categoryId, this.categoryId)) &&
        (subcategoryId == null || identical(subcategoryId, this.subcategoryId)) &&
        (amount == null || identical(amount, this.amount)) &&
        (comment == null || identical(comment, this.comment)) &&
        (dateTime == null || identical(dateTime, this.dateTime)) &&
        (tagIDs == null || identical(tagIDs, this.tagIDs)) &&
        (entryMembers == null || identical(entryMembers, this.entryMembers))) {
      return this;
    }

    return new MyEntry(
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
      entryMembers: entryMembers ?? this.entryMembers,
    );
  }
}
