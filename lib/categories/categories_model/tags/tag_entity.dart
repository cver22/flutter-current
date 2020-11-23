import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'tag_entity.g.dart';

@immutable
@JsonSerializable()
class TagEntity extends Equatable {
  final String id;
  final String name;
  final int logFrequency;

  const TagEntity({this.id, this.name, this.logFrequency});

  @override
  List<Object> get props => [id, name, logFrequency];

  @override
  String toString() {
    return 'MyCategoryEntity {id: $id, name: $name, logFrequency: $logFrequency}';
  }

  factory TagEntity.fromJson(Map<String, dynamic> json) => _$TagEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TagEntityToJson(this);
}
