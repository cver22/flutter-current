import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../../../utils/db_consts.dart';
import '../member_entity.dart';

//part 'entry_member_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class EntryMemberEntity extends MemberEntity {
  final bool paying;
  final bool spending;
  final int paidForeign;
  final int spentForeign;

  EntryMemberEntity({
    uid,
    paid,
    spent,
    order,
    this.paying,
    this.spending = true,
    this.paidForeign = 0,
    this.spentForeign = 0,
  }) : super(uid: uid, paid: paid, spent: spent, order: order);

  @override
  List<Object> get props => [uid, paid, spent, paying, spending, order, paidForeign, spentForeign];

  @override
  String toString() {
    return 'EntryMemberEntity {$UID: $uid, paid: $paid, spent: $spent, paying: $paying, spending: $spending, '
        '$ORDER: $order, $PAID_FOREIGN: $paidForeign, $SPENT_FOREIGN: $spentForeign}';
  }

  //factory EntryMemberEntity.fromJson(Map<String, dynamic> json) => _$EntryMemberEntityFromJson(json);

 // Map<String, dynamic> toJson() => _$EntryMemberEntityToJson(this);
}
