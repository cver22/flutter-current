import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../utils/db_consts.dart';
import '../member.dart';
import 'entry_member_entity.dart';

@immutable
class EntryMember extends Member {
  final bool? paying;
  final bool spending;
  final TextEditingController? payingController;
  final TextEditingController? spendingController;
  final FocusNode? payingFocusNode;
  final FocusNode? spendingFocusNode;
  final bool userEditedSpent;
  final int? paidForeign;
  final int? spentForeign;

  EntryMember({
    required uid,
    paid,
    spent,
    required order,
    this.paying = false,
    this.spending = true,
    this.payingController,
    this.spendingController,
    this.payingFocusNode,
    this.spendingFocusNode,
    this.userEditedSpent = false,
    this.paidForeign,
    this.spentForeign,
  }) : super(uid: uid, paid: paid, spent: spent, order: order);

  @override
  List<Object?> get props => [
        uid,
        paid,
        spent,
        paying,
        spending,
        order,
        paying,
        spending,
        payingController,
        spendingController,
        payingFocusNode,
        spendingFocusNode,
        userEditedSpent,
        paidForeign,
        spentForeign,
      ];

  @override
  String toString() {
    return 'EntryMember {$UID: $uid, paid: $paid, spent: $spent, paying: $paying, spending: $spending, '
        'payingController: $payingController, spendingController: $spendingController, '
        'payingFocusNode: $payingFocusNode, spendingFocusNode: $spendingFocusNode, $ORDER: $order, userEditedSpent: $userEditedSpent, $PAID_FOREIGN: $paidForeign, $SPENT_FOREIGN: $spentForeign}';
  }

  EntryMemberEntity toEntity() {
    return EntryMemberEntity(
      uid: uid,
      paid: paid,
      spent: spent,
      paying: paying,
      spending: spending,
      order: order,
      paidForeign: paidForeign,
      spentForeign: spentForeign,
    );
  }

  static EntryMember fromEntity(EntryMemberEntity entity) {
    return EntryMember(
      uid: entity.uid,
      paid: entity.paid,
      spent: entity.spent,
      paying: entity.paying,
      spending: entity.spending,
      order: entity.order,
      paidForeign: entity.paidForeign,
      spentForeign: entity.spentForeign,
    );
  }

  EntryMember copyWith({
    String? uid,
    int? paid,
    int? spent,
    int? order,
    bool? paying,
    bool? spending,
    TextEditingController? payingController,
    TextEditingController? spendingController,
    FocusNode? payingFocusNode,
    FocusNode? spendingFocusNode,
    bool? userEditedSpent,
    int? paidForeign,
    int? spentForeign,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (paid == null || identical(paid, this.paid)) &&
        (spent == null || identical(spent, this.spent)) &&
        (paying == null || identical(paying, this.paying)) &&
        (spending == null || identical(spending, this.spending)) &&
        (payingController == null || identical(payingController, this.payingController)) &&
        (spendingController == null || identical(spendingController, this.spendingController)) &&
        (payingFocusNode == null || identical(payingFocusNode, this.payingFocusNode)) &&
        (spendingFocusNode == null || identical(spendingFocusNode, this.spendingFocusNode)) &&
        (order == null || identical(order, this.order)) &&
        (userEditedSpent == null || identical(userEditedSpent, this.userEditedSpent)) &&
        (paidForeign == null || identical(paidForeign, this.paidForeign)) &&
        (spentForeign == null || identical(spentForeign, this.spentForeign))) {
      return this;
    }

    return new EntryMember(
      uid: uid ?? this.uid,
      paid: paid ?? this.paid,
      spent: spent ?? this.spent,
      order: order ?? this.order,
      paying: paying ?? this.paying,
      spending: spending ?? this.spending,
      payingController: payingController ?? this.payingController,
      spendingController: spendingController ?? this.spendingController,
      payingFocusNode: payingFocusNode ?? this.payingFocusNode,
      spendingFocusNode: spendingFocusNode ?? this.spendingFocusNode,
      userEditedSpent: userEditedSpent ?? this.userEditedSpent,
      paidForeign: paidForeign ?? this.paidForeign,
      spentForeign: spentForeign ?? this.spentForeign,
    );
  }
}
