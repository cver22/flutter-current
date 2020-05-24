import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/category.dart';
import 'package:expenses/models/categories/subcategory.dart';

class Categories extends Equatable {
  final String logId;
  final String uid;
  final List<Category> categories;
  final List<Subcategory> subcategories;

  //this model requires either a logId to match with that log or a uid to act as a user preferred set of categories
  Categories({this.logId, this.uid, this.categories, this.subcategories});

  @override
  List<Object> get props => [logId, uid, categories, subcategories];

  Categories copyWith({
    String logId,
    String uid,
    List<String> categories,
    List<String> subcategories,
  }) {
    return Categories(
      logId: logId ?? this.logId,
      uid: uid ?? this.uid,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
    );
  }

  @override
  String toString() {
    return 'Categories {logId: $logId, uid: $uid, categories: $categories, subcategories: $subcategories}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Categories &&
          runtimeType == other.runtimeType &&
          logId == other.logId &&
          uid == other.uid &&
          categories == other.categories &&
          subcategories == other.subcategories;
}
