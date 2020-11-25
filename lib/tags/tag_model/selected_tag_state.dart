import 'package:equatable/equatable.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';

@immutable
class SelectedTagState extends Equatable {
  final Maybe<Tag> selectedTag;

  SelectedTagState({this.selectedTag});

  factory SelectedTagState.initial() {
    return SelectedTagState(
      selectedTag: Maybe.none(),
    );
  }

  SelectedTagState copyWith({
    Maybe<Tag> selectedTag,
  }) {
    return SelectedTagState(
      selectedTag: selectedTag ?? this.selectedTag,
    );
  }

  @override
  List<Object> get props => [selectedTag];

  @override
  bool get stringify => true;
}
