import 'package:equatable/equatable.dart';
import 'package:expenses/models/entry/my_entry_entity.dart';
import 'package:flutter/foundation.dart';

class MyEntry extends Equatable {
  //TODO entry members map

  MyEntry(
      {this.id,
      @required this.logId,
      @required this.currency,
      this.active = true,
      this.category,
      this.subcategory,
      @required this.amount,
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
    return 'Log {id: $id, logId: $logId, '
        'currency: $currency, active: $active, category: $category, '
        'subcategory: $subcategory, amount: $amount, comment: $comment, '
        'dateTime: $dateTime}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          logId == other.logId &&
          currency == other.currency &&
          active == other.active &&
          category == other.category &&
          subcategory == other.subcategory &&
          amount == other.amount &&
          comment == other.comment &&
          dateTime == other.dateTime;

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

  MyEntry copy(MyEntry entry) {
    return entry.copyWith(
      id: entry.id,
      logId: entry.logId,
      currency: entry.currency,
      active: entry.active,
      category: entry.category,
      subcategory: entry.subcategory,
      amount: entry.amount,
      comment: entry.comment,
      dateTime: entry.dateTime,
    );
  }
}

class ChangeNotifierEntry extends MyEntry with ChangeNotifier {
  ChangeNotifierEntry myEntry;

  ChangeNotifierEntry({
    id,
    logId,
    currency,
    active,
    category,
    subcategory,
    amount,
    comment,
    dateTime,
  }) : super(
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

  ChangeNotifierEntry initializeEntry(ChangeNotifierEntry entry){
    myEntry = entry;
    return myEntry;
  }


  ChangeNotifierEntry setEntry(ChangeNotifierEntry entry) {
      myEntry = myEntry.copy(entry);
    notifyListeners();
    return myEntry;
  }
}
