import 'package:equatable/equatable.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';

@immutable
class TagState extends Equatable {
  final Maybe<Tag> selectedTag;
  final List<Tag> newTags;

  TagState({this.selectedTag, this.newTags});

  factory TagState.initial() {
    return TagState(
      selectedTag: Maybe.none(),
      newTags: [],
    );
  }

  TagState copyWith({
    Maybe<Tag> selectedTag,
    List<Tag> newTags,
  }) {
    return TagState(
      selectedTag: selectedTag ?? this.selectedTag,
      newTags: newTags ?? this.newTags,
    );
  }

  @override
  List<Object> get props => [selectedTag, newTags];

  @override
  bool get stringify => true;
}
