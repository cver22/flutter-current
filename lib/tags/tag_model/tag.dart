import 'package:equatable/equatable.dart';
import 'package:expenses/tags/tag_model/tag_entity.dart';
import 'package:meta/meta.dart';

@immutable
class Tag extends Equatable {
  final String id;
  final String name;
  final int logFrequency;

  Tag({this.id, this.name, this.logFrequency = 0 });

  Tag copyWith({String id, String name}) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      logFrequency: logFrequency ?? this.logFrequency,
    );
  }

  @override
  String toString() {
    return 'MyCategory {id: $id, name: $name, frequency: $logFrequency}';
  }

  @override
  List<Object> get props => [id, name, logFrequency];

  TagEntity toEntity() {
    return TagEntity(
      id: id,
      name: name,
      logFrequency: logFrequency
    );
  }

  static Tag fromEntity(TagEntity entity) {
    return Tag(
      id: entity.id,
      name: entity.name,
      logFrequency: entity.logFrequency,
    );
  }
}
