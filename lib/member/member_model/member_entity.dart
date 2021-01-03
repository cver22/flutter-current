import 'package:equatable/equatable.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:meta/meta.dart';

@immutable
class MemberEntity extends Equatable {
  final String uid;
  final int paid;
  final int spent;
  final int order;

  MemberEntity({@required this.uid, this.paid = 0, this.spent = 0, this.order});

  @override
  List<Object> get props => [uid, paid, spent, order];

  @override
  String toString() {
    return 'MemberEntity {$UID: $uid, $PAID: $paid, $SPENT: $spent, $ORDER: $order}';
  }
}
