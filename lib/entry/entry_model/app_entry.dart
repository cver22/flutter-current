import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../member/member_model/entry_member_model/entry_member.dart';
import '../../utils/db_consts.dart';
import 'app_entry_entity.dart';

@immutable
class AppEntry extends Equatable with ChangeNotifier {
  AppEntry({
    required this.id,
    required this.logId,
    required this.currency,
    this.categoryId = NO_CATEGORY,
    this.subcategoryId = NO_SUBCATEGORY,
    this.amount = 0,
    this.amountForeign = 0,
    this.exchangeRate = 1.0,
    this.comment = '',
    required this.dateTime,
    this.tagIDs = const [],
    this.entryMembers = const {},
  });

  final String id;
  final String logId;
  final String currency;
  final String categoryId;
  final String subcategoryId;
  final int amount;
  final int amountForeign;
  final double exchangeRate;
  final String comment;
  final DateTime dateTime;
  final List<String?> tagIDs;
  final Map<String, EntryMember> entryMembers;


  @override
  List<Object?> get props =>
      [id, logId, currency, categoryId, subcategoryId, amount, amountForeign, exchangeRate, comment, dateTime, tagIDs, entryMembers];

  @override
  String toString() {
    return 'Entry {id: $id, $LOG_ID: $logId, '
        'currency: $currency, $CATEGORY: $categoryId, '
        '$SUBCATEGORY: $subcategoryId, $AMOUNT: $amount, $AMOUNT_FOREIGN: $amountForeign, $EXCHANGE_RATE: $exchangeRate, '
        '$COMMENT: $comment, $DATE_TIME: $dateTime, tagIDs: $tagIDs, members: $entryMembers}';
  }

  AppEntryEntity toEntity() {
    return AppEntryEntity(
      id: id,
      logId: logId,
      currency: currency,
      category: categoryId,
      subcategory: subcategoryId,
      amount: amount,
      amountForeign: amountForeign,
      exchangeRate: exchangeRate,
      comment: comment,
      dateTime: dateTime,
      tagIDs: Map<String, String>.fromIterable(tagIDs, key: (e) => e, value: (e) => e),
      entryMembers: entryMembers,
      memberList: entryMembers.keys.toList(),
    );
  }

  static AppEntry fromEntity(AppEntryEntity entity) {
    //re-order the entry members as per user preference prior to passing to the entry
    LinkedHashMap<String, EntryMember> entryMembersLinkedMap = LinkedHashMap();
    for (int i = 0; i < entity.entryMembers.length; i++) {
      entity.entryMembers.forEach((key, member) {
        if (member.order == i) {
          entryMembersLinkedMap.putIfAbsent(key, () => member);
        }
      });
    }

    entryMembersLinkedMap = entryMembersLinkedMap; // ordering didn't work, pass the list anyway

    return AppEntry(
      id: entity.id,
      logId: entity.logId,
      currency: entity.currency,
      categoryId: entity.category,
      subcategoryId: entity.subcategory,
      amount: entity.amount,
      amountForeign: entity.amountForeign,
      exchangeRate: entity.exchangeRate,
      comment: entity.comment,
      dateTime: entity.dateTime,
      tagIDs: entity.tagIDs.entries.map((e) => e.value).toList(),
      entryMembers: entryMembersLinkedMap,
    );
  }

  AppEntry copyWith({
    String? id,
    String? logId,
    String? currency,
    String? categoryId,
    String? subcategoryId,
    int? amount,
    int? amountForeign,
    double? exchangeRate,
    String? comment,
    DateTime? dateTime,
    List<String?>? tagIDs,
    Map<String, EntryMember>? entryMembers,
  }) {
    if ((id == null || identical(id, this.id)) &&
        (logId == null || identical(logId, this.logId)) &&
        (currency == null || identical(currency, this.currency)) &&
        (categoryId == null || identical(categoryId, this.categoryId)) &&
        (subcategoryId == null || identical(subcategoryId, this.subcategoryId)) &&
        (amount == null || identical(amount, this.amount)) &&
        (amountForeign == null || identical(amountForeign, this.amountForeign)) &&
        (exchangeRate == null || identical(exchangeRate, this.exchangeRate)) &&
        (comment == null || identical(comment, this.comment)) &&
        (dateTime == null || identical(dateTime, this.dateTime)) &&
        (tagIDs == null || identical(tagIDs, this.tagIDs)) &&
        (entryMembers == null || identical(entryMembers, this.entryMembers))) {
      return this;
    }

    return new AppEntry(
      id: id ?? this.id,
      logId: logId ?? this.logId,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      amount: amount ?? this.amount,
      amountForeign: amountForeign ?? this.amountForeign,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      comment: comment ?? this.comment,
      dateTime: dateTime ?? this.dateTime,
      tagIDs: tagIDs ?? this.tagIDs,
      entryMembers: entryMembers ?? this.entryMembers,
    );
  }
}
