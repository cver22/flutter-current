
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../member/member_model/entry_member_model/entry_member.dart';
import '../../member/member_model/entry_member_model/entry_member_entity.dart';
import '../../utils/db_consts.dart';

@immutable
class AppEntryEntity extends Equatable {
  const AppEntryEntity(
      {required this.id,
        required this.logId,
        required this.currency,
      this.category,
      this.subcategory,
      this.amount = 0,
      this.amountForeign,
      this.exchangeRate,
      this.comment,
      required this.dateTime,
      this.tagIDs = const {},
      this.entryMembers = const {},
      this.memberList = const []}); //TODO get rid of members list eventually? do i need it if I have entryMembers list?

  final String id;
  final String logId;
  final String currency;
  final String? category;
  final String? subcategory;
  final int amount;
  final int? amountForeign;
  final double? exchangeRate;
  final String? comment;
  final DateTime dateTime;
  final Map<String, String> tagIDs;
  final Map<String, EntryMember> entryMembers;
  final List<String> memberList;

  @override
  List<Object?> get props => [
        id,
        logId,
        currency,
        category,
        subcategory,
        amount,
        amountForeign,
        exchangeRate,
        comment,
        dateTime,
        tagIDs,
        entryMembers,
        memberList,
      ];

  @override
  String toString() {
    return 'EntryEntity {$ID: $id, $LOG_ID: $logId, '
        'currency: $currency, $CATEGORY: $category, '
        '$SUBCATEGORY: $subcategory, $AMOUNT: $amount, $AMOUNT_FOREIGN: $amountForeign, $EXCHANGE_RATE: $exchangeRate, '
        '$COMMENT: $comment, $DATE_TIME: $dateTime, tagIDs: $tagIDs, members: $entryMembers, memberList: $memberList)}';
  }

  static AppEntryEntity fromJson(Map<String, Object?> json, String id) {
    return AppEntryEntity(
      id: id,
      logId: json[LOG_ID] as String,
      currency: json[CURRENCY_NAME] as String,
      category: json[CATEGORY] as String?,
      subcategory: json[SUBCATEGORY] as String?,
      amount: json[AMOUNT] as int,
      amountForeign:  json[AMOUNT_FOREIGN] as int?,
      exchangeRate: json[EXCHANGE_RATE] as double?,
      comment: json[COMMENT] as String?,
      dateTime: DateTime.fromMillisecondsSinceEpoch(json[DATE_TIME] as int),
      tagIDs: (json[TAGS] as Map<String, dynamic>).map((key, value) => MapEntry(key, value)),
      entryMembers: (json[MEMBERS] as Map<String, dynamic>).map((key, value) => MapEntry(key, EntryMember.fromEntity(EntryMemberEntity.fromJson(value)))),
    );
  }

  Map<String, Object?> toJson() {
    return {
      LOG_ID: logId,
      CURRENCY_NAME: currency,
      CATEGORY: category,
      SUBCATEGORY: subcategory,
      AMOUNT: amount,
      AMOUNT_FOREIGN: amountForeign,
      EXCHANGE_RATE: exchangeRate,
      COMMENT: comment,
      DATE_TIME: dateTime.millisecondsSinceEpoch,
      TAGS: tagIDs.map((key, value) => MapEntry(key, value)),
      MEMBERS: entryMembers.map((key, value) => MapEntry(key, value.toEntity().toJson())),
      MEMBER_LIST: memberList
    };
  }
}
