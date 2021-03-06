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

  Member({
    required this.uid,
    required this.paid,
    required this.spent,
    this.order,
  });

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
      paid: entity.paid ?? 0,
      spent: entity.spent ?? 0,
      order: entity.order,
    );
  }

  Member copyWith({
    String? uid,
    int? paid,
    int? spent,
    int? order,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (paid == null || identical(paid, this.paid)) &&
        (spent == null || identical(spent, this.spent)) &&
        (order == null || identical(order, this.order))) {
      return this;
    }

    return new Member(
      uid: uid ?? this.uid,
      paid: paid ?? this.paid,
      spent: spent ?? this.spent,
      order: order ?? this.order,
    );
  }
}
