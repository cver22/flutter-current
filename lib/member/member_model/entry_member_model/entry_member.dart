import 'package:expenses/member/member_model/entry_member_model/entry_member_entity.dart';
import 'package:expenses/member/member_model/member.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
class EntryMember extends Member {
  final bool paying;
  final bool spending;
  final TextEditingController payingController;
  final TextEditingController spendingController;
  final FocusNode payingFocusNode;
  final FocusNode spendingFocusNode;

  EntryMember({
    uid,
    paid,
    spent,
    order,
    this.paying = false,
    this.spending = true,
    this.payingController,
    this.spendingController,
    this.payingFocusNode,
    this.spendingFocusNode,
  }) : super(uid: uid, paid: paid, spent: spent, order: order);

  @override
  List<Object> get props => [uid, paid, spent, paying, spending, order];

  @override
  String toString() {
    return 'EntryMember {$UID: $uid, paid: $paid, spent: $spent, paying: $paying, spending: $spending, '
        'payingController: $payingController, spendingController: $spendingController, '
        'payingFocusNode: $payingFocusNode, spendingFocusNode: $spendingFocusNode, $ORDER: $order}';
  }

  EntryMemberEntity toEntity() {
    return EntryMemberEntity(
      uid: uid,
      paid: paid,
      spent: spent,
      paying: paying,
      spending: spending,
      order: order,
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
    );
  }

  EntryMember copyWith({
    String uid,
    int paid,
    int spent,
    int order,
    bool paying,
    bool spending,
    TextEditingController payingController,
    TextEditingController spendingController,
    FocusNode payingFocusNode,
    FocusNode spendingFocusNode,
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
        (order == null || identical(order, this.order))) {
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
    );
  }
}
