import 'package:equatable/equatable.dart';
import '../../utils/db_consts.dart';

class ChartState extends Equatable {
  final ChartGrouping chartGrouping;
  final ChartType chartType;

  ChartState({
    this.chartGrouping = ChartGrouping.day,
    this.chartType = ChartType.line,
  });

  @override
  List<Object?> get props => [chartGrouping, chartType];

  @override
  bool get stringify => true;
}
