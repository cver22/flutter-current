import 'package:equatable/equatable.dart';

import '../../categories/categories_model/app_category/app_category.dart';
import 'package:hive/hive.dart';

part 'settings_hive.g.dart';
//type id can neve3r be changed
@HiveType(typeId: 0)
class SettingsHive {
  //field ids can only be dropped, never changed
  @HiveField(0)
  String homeCurrency;
  @HiveField(1)
  Map<String, List<AppCategory>> defaultCategories;
  @HiveField(2)
  Map<String, List<AppCategory>> defaultSubcategories;
  @HiveField(3)
  String? defaultLogId;
  @HiveField(4)
  bool? autoInsertDecimalPoint;
  @HiveField(5)
  List<String>? logOrder;

  SettingsHive({
    required this.homeCurrency,
    required this.defaultCategories,
    required this.defaultSubcategories,
    this.defaultLogId,
    this.autoInsertDecimalPoint = false,
    this.logOrder,
  });

}
