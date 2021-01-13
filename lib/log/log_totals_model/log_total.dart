import 'package:equatable/equatable.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:meta/meta.dart';

@immutable
class LogTotal extends Equatable {
  final Map<String, LogMember> logMembers;
  final int thisMonthTotalPaid;
  final int lastMonthTotalPaid;
  final int sameMonthLastYearTotalPaid;
  final int averagePerDay;

  LogTotal({
    this.logMembers,
    this.thisMonthTotalPaid,
    this.lastMonthTotalPaid,
    this.sameMonthLastYearTotalPaid,
    this.averagePerDay,
  });

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [logMembers, thisMonthTotalPaid, lastMonthTotalPaid, sameMonthLastYearTotalPaid, averagePerDay];

  LogTotal copyWith({
    Map<String, LogMember> logMembers,
    int thisMonthTotalPaid,
    int lastMonthTotalPaid,
    int sameMonthLastYearTotalPaid,
    int averagePerDay,
  }) {
    if ((logMembers == null || identical(logMembers, this.logMembers)) &&
        (thisMonthTotalPaid == null || identical(thisMonthTotalPaid, this.thisMonthTotalPaid)) &&
        (lastMonthTotalPaid == null || identical(lastMonthTotalPaid, this.lastMonthTotalPaid)) &&
        (sameMonthLastYearTotalPaid == null ||
            identical(sameMonthLastYearTotalPaid, this.sameMonthLastYearTotalPaid)) &&
        (averagePerDay == null || identical(averagePerDay, this.averagePerDay))) {
      return this;
    }

    return new LogTotal(
      logMembers: logMembers ?? this.logMembers,
      thisMonthTotalPaid: thisMonthTotalPaid ?? this.thisMonthTotalPaid,
      lastMonthTotalPaid: lastMonthTotalPaid ?? this.lastMonthTotalPaid,
      sameMonthLastYearTotalPaid: sameMonthLastYearTotalPaid ?? this.sameMonthLastYearTotalPaid,
      averagePerDay: averagePerDay ?? this.averagePerDay,
    );
  }
}
