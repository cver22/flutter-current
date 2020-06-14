import 'package:expenses/models/app_tab.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final AppTab activeTab;

  AppState({@required this.activeTab});

  AppState copyWith({
    AppTab activeTab,
  }) {
    return AppState(
      activeTab: activeTab ?? this.activeTab,
    );
  }

  factory AppState.initial() {
    return AppState(
      activeTab: AppTab.logs,
    );
  }
}
