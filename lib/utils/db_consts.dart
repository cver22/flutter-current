//Shared constants
import 'package:flutter/material.dart';

const String APP = 'app';
const String EXPENSE_APP = 'expenseApp';
const String ID = 'id';
const String UID = 'uid';
const String ACTIVE = 'active'; //used to determine if a file is active or deleted
const String ARCHIVE = 'archive'; //used to determine if log is shown or not
const String CURRENCY_NAME = 'currency';
const String CATEGORY = 'category';
const String SUBCATEGORY = 'subcategory';
const String CATEGORIES = 'categories';
const String SUBCATEGORIES = 'subcategories';
const String NAME = 'name';
const String PARENT_CATEGORY_ID = 'parentCategoryId';
const String DEFAULT_CATEGORY = 'defaultCategory';
enum CategoryOrSubcategory { category, subcategory }
enum SettingsLogFilterEntry { settings, log, filter, entry }
enum EntriesCharts { entries, charts }
enum TagCollectionType { entry, category, log }
enum SortMethod { alphabetical, frequency }
enum DatePickerType { start, end, entry }
//TODO implement filtering later
//enum FilterBy {none, all, category, subcategory, tag}

//Log constants
const String LOG_COLLECTION = 'logs';
const String ENTRIES = 'entries';
const String LOG_NAME = 'logName';
const String MEMBER_ROLES_MAP = 'rolesList';
const String MEMBERS = 'members';
const String MEMBER_LIST = 'memberList';
const String OWNER_OR_WRITER = 'ownerOrWriter';
const String OWNER = 'owner';
const String WRITER = 'write';
const String ORDER = 'order';

//Category constants
const String NO_CATEGORY = 'noCategory';
const String NO_SUBCATEGORY = 'noSubcategory';
const String OTHER = 'other';
const String TRANSFER_FUNDS = 'transferFunds';
const String PAYMENT = 'payment';

//Entry constants
const String ENTRY_COLLECTION = 'entries';
const String LOG_ID = 'logId';
const String ENTRY_NAME = 'entryName';
const String ENTRY_MEMBERS = 'entryMembers';
const String AMOUNT = 'amount';
const String AMOUNT_FOREIGN = 'amountForeign';
const String EXCHANGE_RATE = 'exchangeRate';
const String COMMENT = 'comment';
const String LOCATION = 'location';
const String DATE_TIME = 'dateTime';
enum PaidOrSpent { paid, spent }

//Members constants
const String AMOUNT_MY_CURRENCY = 'amountInMyCurrency';
const String PAID = 'paid';
const String SPENT = 'spent';
const String PAID_FOREIGN = 'paidForeign';
const String SPENT_FOREIGN = 'spentForeign';

//Tags constants
const String TAG_COLLECTION = 'tags';
const String TAGS = 'tags';
const String TAG = 'tag';
const String TAG_LOG_FREQUENCY = 'tagLogFrequency';
const String TAG_CATEGORY_FREQUENCY = 'tagCategoryFrequency';
const String TAG_CATEGORY_LAST_USE = 'tagCategoryLastUse';
const String TAG_SUBCATEGORY_FREQUENCY = 'tagSubcategoryFrequency';
const String TAG_SUBCATEGORY_LAST_USE = 'tagSubcategoryLastUse';
const int MAX_TAGS = 10;

//Account constants
const String PHOTO_URL = 'photoUrl';
const String EMAIL = 'email';
const String MEMBER_NAME = 'memberName';

//Chart constants
enum ChartGrouping { day, month, year }
enum ChartType { line, bar, donut }

//UI constants
const double EMOJI_SIZE = 22.0;
const double ELEVATED_BUTTON_ELEVATION = 3.0;
const double ELEVATED_BUTTON_CIRCULAR_RADIUS = 5.0;
const double DIALOG_ELEVATION = 5.0;
const double DIALOG_BORDER_RADIUS = 10.0;
const double DIALOG_EDGE_INSETS = 25.0;
const Color ACTIVE_HINT_COLOR = Color(0xFF757575);
const Color INACTIVE_HINT_COLOR = Color(0xFFD6D6D6);

//DATE constants
const List<String> MONTHS_LONG = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const List<String> MONTHS_SHORT = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

//HIVE BOXES
const String SETTINGS_BOX = 'settingsBox';
const String SETTINGS_HIVE_INDEX = 'settingsHiveIndex';
const String SETTINGS_INITIALIZED_INDEX = 'settingsInitializedIndex';
const String CURRENCY_BOX = 'currencyBox';
const String CONVERSION_RATE_MAP = 'conversionRateMap';
const String CHART_BOX = 'chartBox';
const String APP_CHART_INDEX = 'appChartIndex';
