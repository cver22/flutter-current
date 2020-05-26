import 'package:equatable/equatable.dart';
import 'package:expenses/res/db_consts.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_entity.g.dart';

@JsonSerializable()
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconCodePoint;
  final String iconFontFamily;

  const CategoryEntity(
      {this.id, this.name, this.iconCodePoint, this.iconFontFamily});

  @override
  List<Object> get props => [id, name, iconCodePoint, iconFontFamily];

  @override
  String toString() {
    return 'CategoryEntity {id: $id, name: $name, iconCodePoint: $iconCodePoint, $ICON_FONT_FAMILY: $iconFontFamily }';
  }

  factory CategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryEntityToJson(this);
}
