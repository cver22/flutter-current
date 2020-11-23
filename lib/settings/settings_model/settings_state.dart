import 'package:equatable/equatable.dart';
import 'package:expenses/settings/settings_model/settings.dart';
import 'package:expenses/utils/maybe.dart';


class SettingsState extends Equatable {
  final Maybe<Settings> settings;

  SettingsState({
    this.settings,
  });

  factory SettingsState.initial() {
    return SettingsState(
      settings: Maybe.none(),
    );
  }

  SettingsState copyWith({
    Maybe<Settings> settings,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object> get props => [settings];

  @override
  bool get stringify => true;
}
