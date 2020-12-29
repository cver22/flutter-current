
import 'package:equatable/equatable.dart';
import 'package:expenses/member/member_model/member_entity.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:meta/meta.dart';

@immutable

class Member extends Equatable{

  final String uid;
  final int paid;
  final int spent;

  Member({@required this.uid, this.paid = 0, this.spent = 0});

  @override
  List<Object> get props => [uid, paid, spent];

  @override
  String toString() {
    return 'LogMember {$UID: $uid, paid: $paid, spent: $spent, }';
  }


  MemberEntity toEntity() {
    return MemberEntity(
      uid: uid,
      paid: paid,
      spent: spent,
    );
  }

  static Member fromEntity(MemberEntity entity) {
    return Member(
      uid: entity.uid,
      paid: entity.paid,
      spent: entity.spent,
    );
  }
}