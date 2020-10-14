import 'package:equatable/equatable.dart';
import 'package:expenses/models/entry/my_entry_entity.dart';
import 'package:expenses/models/log/log.dart';
import 'package:flutter/foundation.dart';

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

  MyEntry changeLog({Log log}) {
    String _logId = this.logId;
    String _category = this.category;
    String _subcategory = this.subcategory;
    String _currency = this.currency;

    if (log.id != this.logId) {
      _logId = log.id;
      _currency = log.currency;
      _category = null;
      _subcategory = null;
    }

    return MyEntry(
      id: this.id,
      logId: _logId ?? this.logId,
      currency: _currency ?? this.currency,
      active: this.active,
      category: _category,
      subcategory: _subcategory,
      amount: this.amount,
      comment: this.comment,
      dateTime: this.dateTime,
    );
  }

  MyEntry changeCategories({
    String category,
  }) {
    //safety checks if category has changed and thus erased the selected subcategory
    String _subcategory;
    if (category == this.category) {
      _subcategory = this.subcategory;
    }

    return MyEntry(
      id: this.id,
      logId: logId ?? this.logId,
      currency: currency ?? this.currency,
      active: this.active,
      category: category,
      subcategory: _subcategory,
      amount: this.amount,
      comment: this.comment,
      dateTime: this.dateTime,
    );
  }

  @override
  List<Object> get props => [id, logId, currency, active, category, subcategory, amount, comment, dateTime];

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
