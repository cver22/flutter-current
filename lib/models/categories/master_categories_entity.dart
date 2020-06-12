import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/res/db_consts.dart';
import 'package:flutter/foundation.dart';


@immutable
class MasterCategoriesEntity extends Equatable{
  final String uid;
  final Map<int, MyCategory> categories;
  final Map<int, MySubcategory> subcategories;

  MasterCategoriesEntity({this.uid, this.categories, this.subcategories});

  @override
  List<Object> get props => [uid, categories, subcategories];

  @override
  String toString() {
    return 'MasterCategoriesEntity {$UID: $uid, $CATEGORIES: $categories, $SUBCATEGORIES: $subcategories}';
  }

  //TODO save to firebase master list or save to file?

}