import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:expenses/res/db_consts.dart';

class EntryEntity extends Equatable {
  final String id;
  final String logId;
  final String entryName;
  final String currency;
  final bool active;
  final String category;
  final String subcategory;
  final double amount;
  final String comment;
  final DateTime dateTime;

  const EntryEntity(
      {this.id,
      this.logId,
      this.entryName,
      this.currency,
      this.active,
      this.category,
      this.subcategory,
      this.amount,
      this.comment,
      this.dateTime});


  @override
  List<Object> get props => [
        id,
        logId,
        entryName,
        currency,
        active,
        category,
        subcategory,
        amount,
        comment,
        dateTime
      ];

  @override
  String toString() {
    return 'Log {id: $id, logId: $logId, entryName: $entryName, '
        'currency: $currency, active: $active, category: $category, '
        'subcategory: $subcategory, amount: $amount, comment: $comment'
        'dateTime: $dateTime)}';
  }


  static EntryEntity fromSnapshot(DocumentSnapshot snap) {
    return EntryEntity(
      id: snap.documentID,
      logId: snap.data[LOG_ID],
      entryName: snap.data[ENTRY_NAME],
      currency: snap.data[CURRENCY_NAME],
      active: snap.data[ACTIVE],
      category: snap.data[CATEGORY],
      subcategory: snap.data[SUBCATEGORY],
      amount: snap.data[AMOUNT],
      comment: snap.data[COMMENT],
      dateTime: snap.data[DATE_TIME],
    );
  }

  Map<String, Object> toDocument() {
    return {
      LOG_ID: logId,
      ENTRY_NAME: entryName,
      CURRENCY_NAME: currency,
      ACTIVE: active,
      CATEGORY: category,
      SUBCATEGORY: subcategory,
      AMOUNT: amount,
      COMMENT: comment,
      DATE_TIME: dateTime
    };
  }
}
