import 'package:expenses/member/member_model/log_member_model/log_member_entity.dart';
import 'package:expenses/member/member_model/member.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:meta/meta.dart';

@immutable

class LogMember extends Member{

  final String name;
  final String role;

  LogMember({uid, paid, spent, this.name, this.role = WRITER}): super (uid: uid, paid: paid, spent: spent);

  @override
  List<Object> get props => [uid, name, paid, spent, role];

  @override
  String toString() {
    return 'LogMember {$UID: $uid, $NAME: $name, paid: $paid, spent: $spent, role: $role}';
  }


  LogMember copyWith({
    String uid,
    String name,
    int paid,
    int spent,
    String role,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (name == null || identical(name, this.name)) &&
        (paid == null || identical(paid, this.paid)) &&
        (spent == null || identical(spent, this.spent)) &&
        (role == null || identical(role, this.role))) {
      return this;
    }

    return LogMember(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      paid: paid ?? this.paid,
      spent: spent ?? this.spent,
      role: role ?? this.role,
    );
  }

  LogMemberEntity toEntity() {
    return LogMemberEntity(
      uid: uid,
      name: name,
      paid: paid,
      spent: spent,
      role: role,
    );
  }

  static LogMember fromEntity(LogMemberEntity entity) {
    return LogMember(
      uid: entity.uid,
      name: entity.name,
      paid: entity.paid,
      spent: entity.spent,
      role: entity.role,

    );
  }
}