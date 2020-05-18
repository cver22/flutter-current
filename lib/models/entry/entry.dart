import 'package:equatable/equatable.dart';
import 'package:expenses/models/entry/entry_entity.dart';
import 'package:flutter/foundation.dart';

class Entry extends Equatable {

  //TODO entry members map

  Entry(
      {this.id,
      @required this.logId,
      this.entryName,
      @required this.currency,
      this.active = true,
      this.category,
      this.subcategory,
      @required this.amount,
      this.comment,
      this.dateTime});

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

  Entry copyWith({
    String id,
    String logId,
    String entryName,
    String currency,
    bool active,
    String category,
    String subcategory,
    double amount,
    String comment,
    DateTime dateTime,
  }) {
    return Entry(
      id: id ?? this.id,
      logId: logId ?? this.logId,
      entryName: entryName ?? this.entryName,
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
        'dateTime: $dateTime}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          logId == other.logId &&
          entryName == other.entryName &&
          currency == other.currency &&
          active == other.active &&
          category == other.category &&
          subcategory == other.subcategory &&
          amount == other.amount &&
          comment == other.comment &&
          dateTime == other.dateTime;

  EntryEntity toEntity() {
    return EntryEntity(
      id: id,
      logId: logId,
      entryName: entryName,
      currency: currency,
      active: active,
      category: category,
      subcategory: subcategory,
      amount: amount,
      comment: comment,
      dateTime: dateTime,
    );
  }

  static Entry fromEntity(EntryEntity entity) {
    return Entry(
      id: entity.id,
      logId: entity.logId,
      entryName: entity.entryName,
      currency: entity.currency,
      active: entity.active,
      category: entity.category,
      subcategory: entity.subcategory,
      amount: entity.amount,
      comment: entity.comment,
      dateTime: entity.dateTime,
    );
  }
}
