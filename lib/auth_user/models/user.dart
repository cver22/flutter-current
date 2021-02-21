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

  User copyWith({
    String displayName,
    String email,
    String photoUrl,
  }) {
    if ((id == null || identical(id, this.id)) &&
        (displayName == null || identical(displayName, this.displayName)) &&
        (email == null || identical(email, this.email)) &&
        (photoUrl == null || identical(photoUrl, this.photoUrl))) {
      return this;
    }

    return new User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
