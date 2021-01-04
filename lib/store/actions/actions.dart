import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/auth_user/models/auth_state.dart';
import 'package:expenses/auth_user/models/user.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/entry/entry_model/entries_state.dart';
import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_model/logs_state.dart';
import 'package:expenses/login_register/login_register_model/login_or_register.dart';
import 'package:expenses/login_register/login_register_model/login_reg_state.dart';
import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:expenses/member/member_model/member.dart';
import 'package:expenses/settings/settings_model/settings.dart';
import 'package:expenses/settings/settings_model/settings_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/currency.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:expenses/tags/tag_model/tag_state.dart';

part 'auth_actions.dart';

part 'login_reg_actions.dart';

part 'logs_actions.dart';

part 'entries_actions.dart';

part 'settings_actions.dart';

part 'single_entry_actions.dart';

part 'tag_actions.dart';

abstract class Action {
  AppState updateState(AppState appState);
}

AppState _updateLogEntriesTagSettingState(
    AppState appState,
    LogsState updateLogState(LogsState logsState),
    EntriesState updateEntriesState(EntriesState entriesState),
    TagState updateTagState(TagState tagState),
    SettingsState updateSettingsState(SettingsState settingsState)) {
  return appState.copyWith(
      logsState: updateLogState(appState.logsState),
      entriesState: updateEntriesState(appState.entriesState),
      tagState: updateTagState(appState.tagState),
      settingsState: updateSettingsState(appState.settingsState));
}

class DeleteLog implements Action {
  //This action updates multiple states simultaneously
  final Log log;

  DeleteLog({this.log});

  @override
  AppState updateState(AppState appState) {
    LogsState updatedLogsState = appState.logsState;
    Settings settings = appState.settingsState.settings.value;
    updatedLogsState.logs.removeWhere((key, value) => key == log.id);

    List<MyEntry> deletedEntriesList = [];
    List<Tag> deletedTagsList = [];
    Map<String, MyEntry> entriesMap = Map.from(appState.entriesState.entries);
    Map<String, Tag> tagsMap = Map.from(appState.tagState.tags);

    entriesMap.forEach((key, entry) {
      if (entry.logId == log.id) {
        deletedEntriesList.add(entry);
      }
    });

    entriesMap.removeWhere((key, entry) => entry.logId == log.id);

    tagsMap.forEach((key, tag) {
      if (tag.logId == log.id) {
        deletedTagsList.add(tag);
      }
    });

    tagsMap.removeWhere((key, tag) => tag.logId == log.id);

    //TODO likely need a method to reset the default to nothing, else statement for the above
    //ensures the default log is updated if the current log is default and deleted
    if (appState.settingsState.settings.value.defaultLogId == log.id && updatedLogsState.logs.isNotEmpty) {
      settings = settings.copyWith(
          defaultLogId: updatedLogsState.logs.values.firstWhere((element) => element.id != log.id).id);
    }

    Env.entriesFetcher.batchDeleteEntries(deletedEntries: deletedEntriesList);
    Env.tagFetcher.batchDeleteTags(deletedTags: deletedTagsList);
    Env.logsFetcher.deleteLog(log: log);

    return _updateLogEntriesTagSettingState(
        appState,
        (logsState) => updatedLogsState.copyWith(selectedLog: Maybe.none()),
        (entriesState) => entriesState.copyWith(entries: entriesMap),
        (tagState) => tagState.copyWith(tags: tagsMap),
        (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)));
  }
}

AppState _updateTagSingleEntryState(
  AppState appState,
  TagState updateTagState(TagState tagState),
  SingleEntryState update(SingleEntryState singleEntryState),
) {
  return appState.copyWith(
      tagState: updateTagState(appState.tagState), singleEntryState: update(appState.singleEntryState));
}

class DeleteTagFromEntryScreen implements Action {
  final Tag tag;

  DeleteTagFromEntryScreen({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Map<String, Tag> tagsMap = Map.from(appState.tagState.tags);
    Map<String, Tag> entryTagsMap = Map.from(appState.singleEntryState.tags);
    tagsMap.removeWhere((key, value) => key == tag.id);
    entryTagsMap.removeWhere((key, value) => key == tag.id);

    Env.tagFetcher.deleteTag(tag);

    return _updateTagSingleEntryState(appState, (tagState) => tagState.copyWith(tags: tagsMap),
        (singleEntryState) => singleEntryState.copyWith(tags: entryTagsMap));
  }
}
