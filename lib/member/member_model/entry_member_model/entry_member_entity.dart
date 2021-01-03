import 'package:expenses/member/member_model/member_entity.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'entry_member_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class EntryMemberEntity extends MemberEntity{

  final bool paying;
  final bool spending;

  EntryMemberEntity({uid, paid, spent, order, this.paying, this.spending = true}): super (uid: uid, paid: paid, spent: spent, order: order);

  @override
  List<Object> get props => [uid, paid, spent, paying, spending, order];

  @override
  String toString() {
    return 'EntryMemberEntity {$UID: $uid, paid: $paid, spent: $spent, paying: $paying, spending: $spending $ORDER: $order}';
  }

  factory EntryMemberEntity.fromJson(Map<String, dynamic> json) =>
      _$EntryMemberEntityFromJson(json);

  Map<String, dynamic> toJson() => _$EntryMemberEntityToJson(this);

}