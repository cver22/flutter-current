import 'dart:collection';

import 'package:equatable/equatable.dart';

import 'tag.dart';

class TagState extends Equatable {
  final Map<String, Tag> tags;
  final bool isLoading;

  TagState({this.tags, this.isLoading});

  factory TagState.initial() {
    return TagState(
      tags: LinkedHashMap(),
      isLoading: false,
    );
  }

  TagState copyWith({
    Map<String, Tag> tags,
    bool isLoading,
  }) {
    if ((tags == null || identical(tags, this.tags)) &&
        (isLoading == null || identical(isLoading, this.isLoading))) {
      return this;
    }

    return new TagState(
      tags: tags ?? this.tags,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [tags, isLoading];

  @override
  bool get stringify => true;
}
