import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../utils/db_consts.dart';
import 'member_entity.dart';

@immutable
class Member extends Equatable {
  final String uid;
  final int? paid;
  final int? spent;
  final int? order;

  Member({required this.uid, this.paid, this.spent, this.order});

  @override
  List<Object?> get props => [uid, paid, spent, order];

  @override
  String toString() {
    return 'LogMember {$UID: $uid, $PAID: $paid, $SPENT: $spent, $ORDER: $order}';
  }

  MemberEntity toEntity() {
    return MemberEntity(
      uid: uid,
      paid: paid,
      spent: spent,
      order: order,
    );
  }

  static Member fromEntity(MemberEntity entity) {
    return Member(
      uid: entity.uid,
      paid: entity.paid,
      spent: entity.spent,
      order: entity.order,
    );
  }
}
