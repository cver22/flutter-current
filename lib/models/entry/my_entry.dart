import 'package:equatable/equatable.dart';
import 'package:expenses/models/entry/my_entry_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

@immutable
class MyEntry extends Equatable with ChangeNotifier {
  //TODO entry members map

  MyEntry(
      {this.id,
      this.logId,
      this.currency,
      this.active = true,
      this.category,
      this.subcategory,
      this.amount,
      this.comment,
      this.dateTime});

  final String id;
  final String logId;
  final String currency;
  final bool active;
  final String category;
  final String subcategory;
  final double amount;
  final String comment;
  final DateTime dateTime;

  MyEntry copyWith({
    String id,
    String logId,
    String currency,
    bool active,
    String category,
    String subcategory,
    double amount,
    String comment,
    DateTime dateTime,
  }) {
    return MyEntry(
      id: id ?? this.id,
      logId: logId ?? this.logId,
      currency: currency ?? this.currency,
      active: active ?? this.active,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      amount: amount ?? this.amount,
      comment: comment ?? this.comment,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  MyEntry changeLog({
    String logId,
    String currency,
  }) {
    return MyEntry(
      id: this.id,
      logId: logId ?? this.logId,
      currency: currency ?? this.currency,
      active: this.active,
      category: null,
      subcategory: null,
      amount: this.amount,
      comment: this.comment,
      dateTime: this.dateTime,
    );
  }

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
        dateTime
      ];

  @override
  String toString() {
    return 'Entry {id: $id, logId: $logId, '
        'currency: $currency, active: $active, category: $category, '
        'subcategory: $subcategory, amount: $amount, comment: $comment, '
        'dateTime: $dateTime}';
  }

  MyEntryEntity toEntity() {
    return MyEntryEntity(
      id: id,
      logId: logId,
      currency: currency,
      active: active,
      category: category,
      subcategory: subcategory,
      amount: amount,
      comment: comment,
      dateTime: dateTime,
    );
  }

  static MyEntry fromEntity(MyEntryEntity entity) {
    return MyEntry(
      id: entity.id,
      logId: entity.logId,
      currency: entity.currency,
      active: entity.active,
      category: entity.category,
      subcategory: entity.subcategory,
      amount: entity.amount,
      comment: entity.comment,
      dateTime: entity.dateTime,
    );
  }

/*MyEntry copy(MyEntry entry) {
    return entry.copyWith(
      id: entry?.id ?? this.id,
      logId: entry?.logId ?? this.logId,
      currency: entry?.currency ?? this.currency,
      active: entry?.active ?? this.active,
      category: entry?.category ?? this.category,
      subcategory: entry?.subcategory ?? this.subcategory,
      amount: entry?.amount ?? this.amount,
      comment: entry?.comment ?? this.comment,
      dateTime: entry?.dateTime ?? this.dateTime,
    );
  }*/
}
