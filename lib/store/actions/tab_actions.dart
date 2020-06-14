part of 'actions.dart';

class SelectActiveTab implements Action {
  final AppTab activeTab;

  SelectActiveTab({this.activeTab});

  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(activeTab: activeTab);
  }
}
