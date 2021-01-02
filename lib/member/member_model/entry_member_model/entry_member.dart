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
    this.paying = false,
    this.spending = true,
    this.payingController,
    this.spendingController,
    this.payingFocusNode,
    this.spendingFocusNode,
  }) : super(uid: uid, paid: paid, spent: spent);

  @override
  List<Object> get props => [uid, paid, spent, paying, spending];

  @override
  String toString() {
    return 'EntryMember {$UID: $uid, paid: $paid, spent: $spent, paying: $paying, spending: $spending, '
        'payingController: $payingController, spendingController: $spendingController, '
        'payingFocusNode: $payingFocusNode, spendingFocusNode: $spendingFocusNode}';
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

  EntryMember copyWith({
    String uid,
    int paid,
    int spent,
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
        (spendingFocusNode == null || identical(spendingFocusNode, this.spendingFocusNode))) {
      return this;
    }

    return new EntryMember(
      uid: uid ?? this.uid,
      paid: paid ?? this.paid,
      spent: spent ?? this.spent,
      paying: paying ?? this.paying,
      spending: spending ?? this.spending,
      payingController: payingController ?? this.payingController,
      spendingController: spendingController ?? this.spendingController,
      payingFocusNode: payingFocusNode ?? this.payingFocusNode,
      spendingFocusNode: spendingFocusNode ?? this.spendingFocusNode,
    );
  }
}
