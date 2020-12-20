
import 'package:equatable/equatable.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'member_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class MemberEntity extends Equatable{

  final String uid;
  final double paid;
  final double spent;


  MemberEntity({@required this.uid, this.paid = 0.0, this.spent = 0.0});

  @override
  List<Object> get props => [uid, paid, spent];

  @override
  String toString() {
    return 'LogMemberEntity {$UID: $uid, paid: $paid, spent: $spent}';
  }

  MemberEntity copyWith({
    String uid,
    double paid,
    double spent,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (paid == null || identical(paid, this.paid)) &&
        (spent == null || identical(spent, this.spent))) {
      return this;
    }

    return new MemberEntity(
      uid: uid ?? this.uid,
      paid: paid ?? this.paid,
      spent: spent ?? this.spent,
    );
  }

  factory MemberEntity.fromJson(Map<String, dynamic> json) =>
      _$MemberEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MemberEntityToJson(this);

}