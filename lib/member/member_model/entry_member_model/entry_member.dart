

import 'package:expenses/member/member_model/entry_member_model/entry_member_entity.dart';
import 'package:expenses/member/member_model/member.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:meta/meta.dart';

@immutable
class EntryMember extends Member {
  final bool paying;
  final bool spending;

  EntryMember({uid, paid, spent, this.paying = false, this.spending = true}): super (uid: uid, paid: paid, spent: spent);

  @override
  List<Object> get props => [uid, paid, spent, paying, spending];

  @override
  String toString() {
    return 'EntryMember {$UID: $uid, paid: $paid, spent: $spent, paying: $paying, spending: $spending}';
  }

  EntryMember copyWith({
    String uid,
    double paid,
    double spent,
    bool paying,
    bool spending,

  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (paid == null || identical(paid, this.paid)) &&
        (spent == null || identical(spent, this.spent)) &&
        (paying == null || identical(paying, this.paying)) &&
        (spending == null || identical(spending, this.spending))) {
      return this;
    }

    return EntryMember(
      uid: uid ?? this.uid,
      paid: paid ?? this.paid,
      spent: spent ?? this.spent,
      paying: paying ?? this.paying,
      spending: spending ?? this.spending,
    );
  }

  EntryMemberEntity toEntity() {
    return EntryMemberEntity(
      uid: uid,
      paid: paid,
      spent: spent,
      paying: paying,
      spending: spending,
    );
  }

  static EntryMember fromEntity(EntryMemberEntity entity) {
    return EntryMember(
      uid: entity.uid,
      paid: entity.paid,
      spent: entity.spent,
      paying: entity.paying,
      spending: entity.spending,
    );
  }
}