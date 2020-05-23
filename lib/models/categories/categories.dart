import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/category.dart';

class Categories extends Equatable {
  final String logId;
  final String uid;
  final List<Category> categories;

  //this model requires either a logId to match with that log or a uid to act as a user preferred set of categories
  Categories({this.logId, this.uid, this.categories});

  @override
  List<Object> get props => [logId, uid, categories];

  Categories copyWith({
    String logId,
    String uid,
    List<String> categories,
  }) {
    return Categories(
      logId: logId ?? this.logId,
      uid: uid ?? this.uid,
      categories: categories ?? this.categories,
    );
  }

  @override
  String toString() {
    return 'Categories {logId: $logId, uid: $uid, categories: $categories}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Categories &&
          runtimeType == other.runtimeType &&
          logId == other.logId &&
          uid == other.uid &&
          categories == other.categories;

}
