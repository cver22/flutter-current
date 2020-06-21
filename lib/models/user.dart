import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class User extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final String photoUrl;

  User({this.id, this.displayName, this.email, this.photoUrl});

  @override
  List<Object> get props => [id, displayName, email, photoUrl];

  @override
  String toString() {
    return 'UserEntity{id: $id, displayName: $displayName, email: $email, photoUrl: $photoUrl}';
  }

}