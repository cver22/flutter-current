import 'package:equatable/equatable.dart';
import 'package:expenses/entry/entry_model/my_entry_entity.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:flutter/foundation.dart';

@immutable
class MyEntry extends Equatable with ChangeNotifier {
  //TODO entry members map

  MyEntry(
      {this.id,
      this.logId,
      this.currency,
      this.active = true,
      this.categoryId,
      this.subcategoryId,
      this.amount,
      this.comment,
      this.dateTime});

  final String id;
  final String logId;
  final String currency;
  final bool active;
  final String categoryId;
  final String subcategoryId;
  final double amount;
  final String comment;
  final DateTime dateTime;

  MyEntry copyWith({
    String id,
    String logId,
    String currency,
    bool active,
    String categoryId,
    String subcategoryId,
    double amount,
    String comment,
    DateTime dateTime,
  }) {
    return MyEntry(
      id: id ?? this.id,
      logId: logId ?? this.logId,
      currency: currency ?? this.currency,
      active: active ?? this.active,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      amount: amount ?? this.amount,
      comment: comment ?? this.comment,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  MyEntry changeLog({Log log}) {
    String _logId = this.logId;
    String _category = this.categoryId;
    String _subcategory = this.subcategoryId;
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
      categoryId: _category,
      subcategoryId: _subcategory,
      amount: this.amount,
      comment: this.comment,
      dateTime: this.dateTime,
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
      id: this.id,
      logId: logId ?? this.logId,
      currency: currency ?? this.currency,
      active: this.active,
      categoryId: category,
      subcategoryId: _subcategory,
      amount: this.amount,
      comment: this.comment,
      dateTime: this.dateTime,
    );
  }

  @override
  List<Object> get props => [id, logId, currency, active, categoryId, subcategoryId, amount, comment, dateTime];

  @override
  String toString() {
    return 'Entry {id: $id, logId: $logId, '
        'currency: $currency, active: $active, category: $categoryId, '
        'subcategory: $subcategoryId, amount: $amount, comment: $comment, '
        'dateTime: $dateTime}';
  }

  MyEntryEntity toEntity() {
    return MyEntryEntity(
      id: id,
      logId: logId,
      currency: currency,
      active: active,
      category: categoryId,
      subcategory: subcategoryId,
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
      categoryId: entity.category,
      subcategoryId: entity.subcategory,
      amount: entity.amount,
      comment: entity.comment,
      dateTime: entity.dateTime,
    );
  }

}
