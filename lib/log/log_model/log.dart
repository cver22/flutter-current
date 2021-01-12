import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_model/my_subcategory/my_subcategory.dart';
import 'package:expenses/log/log_model/log_entity.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

@immutable
class Log extends Equatable {
  //TODO log keeps track of who owes who how much "debt map"?
  //TODO need default to last or home currency for entries in this log
  //TODO each log to have its own settings

  Log(
      {this.uid,
      this.id,
      this.name,
      this.currency,
      this.categories,
      this.subcategories,
      this.archive = false,
      this.defaultCategory,
      this.logMembers,
      this.thisMonthTotalPaid = 0,
      this.lastMonthTotalPaid = 0,
      this.sameMonthLastYearTotalPaid = 0,
      this.averagePerDay = 0});

  final String uid;
  final String id;
  final String name;
  final String currency;
  final bool archive;
  final String defaultCategory;
  final List<MyCategory> categories;
  final List<MySubcategory> subcategories;
  final Map<String, LogMember> logMembers;
  final int thisMonthTotalPaid;
  final int lastMonthTotalPaid;
  final int sameMonthLastYearTotalPaid;
  final int averagePerDay;

  //TODO both of these should be move to the actions/logic section
  Log addEditLogCategories({Log log, MyCategory category}) {
    List<MyCategory> categories = log.categories;

    //update category if it already exists
    //otherwise add category to the list
    if (category?.id != null) {
      categories[categories.indexWhere((e) => e.id == category.id)] = category;
    } else {
      categories.add(category.copyWith(id: Uuid().v4()));
    }
    return log.copyWith(categories: categories);
  }

  Log addEditLogSubcategories({Log log, MySubcategory subcategory}) {
    List<MySubcategory> subcategories = log.subcategories;

    //update subcategory if it already exists
    //otherwise add subcategory to the list
    if (subcategory?.id != null) {
      subcategories[subcategories.indexWhere((e) => e.id == subcategory.id)] = subcategory;
    } else {
      subcategories.add(subcategory.copyWith(id: Uuid().v4()));
    }

    return log.copyWith(subcategories: subcategories);
  }

  @override
  List<Object> get props =>
      [uid, id, name, currency, categories, subcategories, archive, defaultCategory, logMembers, thisMonthTotalPaid, lastMonthTotalPaid, sameMonthLastYearTotalPaid, averagePerDay];

  @override
  String toString() {
    return 'Log {$UID: $uid, $ID: $id, $LOG_NAME: $name, currency: $currency, $CATEGORIES: $categories,  '
        '$SUBCATEGORIES: $subcategories, $ARCHIVE: $archive, $DEFAULT_CATEGORY: $defaultCategory, members: $logMembers, '
        'thisMonthTotalPaid: $thisMonthTotalPaid, lastMonthTotalPaid: $lastMonthTotalPaid, '
        'sameMonthLastYearTotalPaid: $sameMonthLastYearTotalPaid}';
  }

  LogEntity toEntity() {
    return LogEntity(
      uid: uid,
      id: id,
      name: name,
      currency: currency,
      categories: Map<String, MyCategory>.fromIterable(categories,
          key: (e) => categories.indexOf(e).toString(), value: (e) => e),
      subcategories: Map<String, MySubcategory>.fromIterable(subcategories,
          key: (e) => subcategories.indexOf(e).toString(), value: (e) => e),
      archive: archive,
      defaultCategory: defaultCategory,
      logMembers: logMembers,
      memberList: logMembers.keys.toList(),
    );
  }

  static Log fromEntity(LogEntity entity) {
    //reorder the log members as per the user's preference prior to passing to the log
    LinkedHashMap<String, LogMember> logMemberHashMap = LinkedHashMap();

    for (int i = 0; i < entity.logMembers.length; i++) {
      entity.logMembers.forEach((key, value) {
        if (value.order == i) {
          logMemberHashMap.putIfAbsent(key, () => value);
        }
      });
    }

    return Log(
      uid: entity.uid,
      id: entity.id,
      name: entity.name,
      currency: entity.currency,
      categories: entity.categories.entries.map((e) => e.value).toList(),
      subcategories: entity.subcategories.entries.map((e) => e.value).toList(),
      archive: entity.archive,
      defaultCategory: entity.defaultCategory,
      logMembers: logMemberHashMap,
    );
  }

  Log copyWith({
    String uid,
    String id,
    String name,
    String currency,
    bool archive,
    String defaultCategory,
    List<MyCategory> categories,
    List<MySubcategory> subcategories,
    Map<String, LogMember> logMembers,
    int thisMonthTotalPaid,
    int lastMonthTotalPaid,
    int sameMonthLastYearTotalPaid,
    int averagePerDay,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (id == null || identical(id, this.id)) &&
        (name == null || identical(name, this.name)) &&
        (currency == null || identical(currency, this.currency)) &&
        (archive == null || identical(archive, this.archive)) &&
        (defaultCategory == null || identical(defaultCategory, this.defaultCategory)) &&
        (categories == null || identical(categories, this.categories)) &&
        (subcategories == null || identical(subcategories, this.subcategories)) &&
        (logMembers == null || identical(logMembers, this.logMembers)) &&
        (thisMonthTotalPaid == null || identical(thisMonthTotalPaid, this.thisMonthTotalPaid)) &&
        (lastMonthTotalPaid == null || identical(lastMonthTotalPaid, this.lastMonthTotalPaid)) &&
        (sameMonthLastYearTotalPaid == null ||
            identical(sameMonthLastYearTotalPaid, this.sameMonthLastYearTotalPaid)) &&
        (averagePerDay == null || identical(averagePerDay, this.averagePerDay))) {
      return this;
    }

    return new Log(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      archive: archive ?? this.archive,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      logMembers: logMembers ?? this.logMembers,
      thisMonthTotalPaid: thisMonthTotalPaid ?? this.thisMonthTotalPaid,
      lastMonthTotalPaid: lastMonthTotalPaid ?? this.lastMonthTotalPaid,
      sameMonthLastYearTotalPaid: sameMonthLastYearTotalPaid ?? this.sameMonthLastYearTotalPaid,
      averagePerDay: averagePerDay ?? this.averagePerDay,
    );
  }


}
