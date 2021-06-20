import 'package:equatable/equatable.dart';
import '../../utils/db_consts.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

@immutable
//type id can never be changed
@HiveType(typeId: 3)
class AppChart extends Equatable {
  //field ids can only be dropped, not changed
  @HiveField(0)
  final ChartDateGrouping chartDateGrouping;
  @HiveField(1)
  final ChartType chartType;
  //@HiveField(2) unused
  //final String uid; unused

  AppChart({
    this.chartDateGrouping = ChartDateGrouping.day,
    this.chartType = ChartType.line
  });

  @override
  List<Object?> get props => [chartDateGrouping, chartType];

  @override
  bool get stringify => true;
}
