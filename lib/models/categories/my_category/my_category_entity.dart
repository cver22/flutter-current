import 'package:equatable/equatable.dart';
import 'package:expenses/res/db_consts.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_category_entity.g.dart';

@JsonSerializable()
class MyCategoryEntity extends Equatable {
  final String name;
  final String iconCodePoint;
  final String iconFontFamily;

  const MyCategoryEntity(
      {this.name, this.iconCodePoint, this.iconFontFamily});

  @override
  List<Object> get props => [name, iconCodePoint, iconFontFamily];

  @override
  String toString() {
    return 'MyCategoryEntity {name: $name, iconCodePoint: $iconCodePoint, $ICON_FONT_FAMILY: $iconFontFamily }';
  }

  factory MyCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$MyCategoryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MyCategoryEntityToJson(this);
}
