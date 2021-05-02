import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../utils/db_consts.dart';

class QRModel extends Equatable {
  final String uid;
  final String name;

  QRModel({@required this.uid, @required this.name});

  @override
  // TODO: implement props
  List<Object> get props => [uid, name];

  QRModel copyWith({
    String uid,
    String name,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (name == null || identical(name, this.name))) {
      return this;
    }

    return new QRModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
    );
  }

  factory QRModel.fromJson(Map<String, dynamic> json) {
    return QRModel(
      uid: json[UID] as String,
      name: json[NAME] as String,
    );
  }

  Map<String, Object> toJson() {
    return {
      APP: EXPENSE_APP,
      UID: uid,
      NAME: name,
    };
  }
}
