import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../utils/db_consts.dart';

@immutable
class MemberEntity extends Equatable {
  final String uid;
  final int? paid;
  final int? spent;
  final int? order;

  MemberEntity({required this.uid, this.paid, this.spent, this.order});

  @override
  List<Object?> get props => [uid, paid, spent, order];

  @override
  String toString() {
    return 'MemberEntity {$UID: $uid, $PAID: $paid, $SPENT: $spent, $ORDER: $order}';
  }
}
