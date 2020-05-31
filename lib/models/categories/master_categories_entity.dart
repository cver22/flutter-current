import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/res/db_consts.dart';


class MasterCategoriesEntity extends Equatable{
  final String uid;
  final Map<String, MyCategory> categories;
  final Map<String, MySubcategory> subcategories;

  MasterCategoriesEntity({this.uid, this.categories, this.subcategories});

  @override
  // TODO: implement props
  List<Object> get props => [uid, categories, subcategories];

  @override
  String toString() {
    return 'MasterCategoriesEntity {$UID: $uid, $CATEGORIES: $categories, $SUBCATEGORIES: $subcategories}';
  }

  //TODO save to firebase master list or save to file?

}