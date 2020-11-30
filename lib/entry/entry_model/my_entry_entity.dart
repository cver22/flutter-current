import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/foundation.dart';


@immutable
class MyEntryEntity extends Equatable {
  final String id;
  final String logId;
  final String currency;
  final bool active;
  final String category;
  final String subcategory;
  final double amount;
  final String comment;
  final DateTime dateTime;
  final Map<String, String> tagIDs;

  const MyEntryEntity(
      {this.id,
      this.logId,
      this.currency,
      this.active,
      this.category,
      this.subcategory,
      this.amount,
      this.comment,
      this.dateTime,
      this.tagIDs});

  @override
  List<Object> get props => [
        id,
        logId,
        currency,
        active,
        category,
        subcategory,
        amount,
        comment,
        dateTime,
    tagIDs,
      ];

  @override
  String toString() {
    return 'Log {id: $id, logId: $logId, '
        'currency: $currency, active: $active, category: $category, '
        'subcategory: $subcategory, amount: $amount, comment: $comment'
        'dateTime: $dateTime, tagIDs: $tagIDs)}';
  }

  static MyEntryEntity fromSnapshot(DocumentSnapshot snap) {
    return MyEntryEntity(
      id: snap.documentID,
      logId: snap.data[LOG_ID],
      currency: snap.data[CURRENCY_NAME],
      active: snap.data[ACTIVE],
      category: snap.data[CATEGORY],
      subcategory: snap.data[SUBCATEGORY],
      amount: snap.data[AMOUNT],
      comment: snap.data[COMMENT],
      dateTime: DateTime.fromMillisecondsSinceEpoch(snap.data[DATE_TIME]),
      tagIDs: (snap.data[TAGS] as Map<String, dynamic>)?.map(
              (key, value) => MapEntry(
              key, value)),

    );
  }

  Map<String, Object> toDocument() {
    return {
      LOG_ID: logId,
      CURRENCY_NAME: currency,
      ACTIVE: active,
      CATEGORY: category,
      SUBCATEGORY: subcategory,
      AMOUNT: amount,
      COMMENT: comment,
      DATE_TIME: dateTime.millisecondsSinceEpoch,
      TAGS: tagIDs
          .map((key, value) => MapEntry(key, value)),
    };
  }
}
