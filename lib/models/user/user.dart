
//TODO also create a model to work with the entity

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final String photoUrl;

  User({this.id, this.displayName, this.email, this.photoUrl});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              displayName == other.displayName &&
              email == other.email &&
              photoUrl == other.photoUrl;


  @override
  List<Object> get props => [id, displayName, email, photoUrl];

  @override
  String toString() {
    return 'UserEntity{id: $id, displayName: $displayName, email: $email, photoUrl: $photoUrl}';
  }

}