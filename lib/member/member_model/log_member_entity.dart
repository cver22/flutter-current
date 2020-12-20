import 'package:expenses/member/member_model/member_entity.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'log_member_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class LogMemberEntity extends MemberEntity{

  final String name;
  final String role;

  LogMemberEntity({uid, paid, spent, this.name, this.role = WRITER}): super (uid: uid, paid: paid, spent: spent);

  @override
  List<Object> get props => [uid, name, paid, spent, role];

  @override
  String toString() {
    return 'LogMemberEntity {$UID: $uid, $NAME: $name, paid: $paid, spent: $spent, role: $role}';
  }

  LogMemberEntity copyWith({
    String uid,
    String name,
    double paid,
    double spent,
    String role,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (name == null || identical(name, this.name)) &&
        (paid == null || identical(paid, this.paid)) &&
        (spent == null || identical(spent, this.spent)) &&
        (role == null || identical(role, this.role))) {
      return this;
    }

    return new LogMemberEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      paid: paid ?? this.paid,
      spent: spent ?? this.spent,
      role: role ?? this.role,
    );
  }

  factory LogMemberEntity.fromJson(Map<String, dynamic> json) =>
      _$LogMemberEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LogMemberEntityToJson(this);

}