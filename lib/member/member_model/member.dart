
import 'package:equatable/equatable.dart';
import 'package:expenses/member/member_model/member_entity.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:meta/meta.dart';

@immutable

class Member extends Equatable{

  final String uid;
  final double paid;
  final double spent;

  Member({@required this.uid, this.paid = 0.0, this.spent = 0.0});

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

  Member copyWith({
    String uid,
    double paid,
    double spent,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (paid == null || identical(paid, this.paid)) &&
        (spent == null || identical(spent, this.spent))) {
      return this;
    }

    return new Member(
      uid: uid ?? this.uid,
      paid: paid ?? this.paid,
      spent: spent ?? this.spent,
    );
  }
}