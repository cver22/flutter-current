import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String category;
  final List<String> subcategories;

  Category({this.category, this.subcategories});

  @override
  List<Object> get props => [category, subcategories];

  Category copyWith({
    String category,
    List<String> subcategories,
  }) {
    return Category(
      category: category ?? this.category,
      subcategories: subcategories ?? this.subcategories,
    );
  }

  @override
  String toString() {
    return 'Category {category: $category, subcategories: $subcategories}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          subcategories == other.subcategories;
}
