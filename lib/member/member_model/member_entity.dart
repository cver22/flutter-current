import 'package:equatable/equatable.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:meta/meta.dart';

@immutable
class MemberEntity extends Equatable {
  final String uid;
  final int paid;
  final int spent;

  MemberEntity({@required this.uid, this.paid = 0, this.spent = 0});

  @override
  List<Object> get props => [uid, paid, spent];

  @override
  String toString() {
    return 'LogMemberEntity {$UID: $uid, paid: $paid, spent: $spent}';
  }
}
