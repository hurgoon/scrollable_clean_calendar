import 'package:scrollable_clean_calendar/utils/date_models.dart';

class WeekHelper {
  static List<Month> extractWeeks(DateTime minDate, DateTime maxDate,
      [int startWeekDay = DateTime.monday]) {
    DateTime weekMinDate = _findDayOfWeekInMonth(minDate, startWeekDay = DateTime.sunday);

    final oneWeek = (startWeekDay + 5) > 6
        ? ((startWeekDay + 5) - 6).abs()
        : (startWeekDay + 5);

    DateTime weekMaxDate = _findDayOfWeekInMonth(maxDate, oneWeek);

    DateTime firstDayOfWeek = weekMinDate;
    DateTime lastDayOfWeek = _lastDayOfWeek(weekMinDate);

    if (!lastDayOfWeek.isBefore(weekMaxDate)) {
      return <Month>[
        Month(<Week>[Week(firstDayOfWeek, lastDayOfWeek)])
      ];
    } else {
      List<Month> months = [];
      List<Week> weeks = [];

      while (lastDayOfWeek.isBefore(weekMaxDate)) {
        Week week = Week(firstDayOfWeek, lastDayOfWeek);
        weeks.add(week);

        if (week.isLastWeekOfMonth) {
          if (lastDayOfWeek.isSameDayOrAfter(minDate)) {
            months.add(Month(weeks));
          }

          weeks = [];

          firstDayOfWeek = firstDayOfWeek.toFirstDayOfNextMonth();
          lastDayOfWeek = _lastDayOfWeek(firstDayOfWeek);

          weeks.add(Week(firstDayOfWeek, lastDayOfWeek));
        }

        firstDayOfWeek = lastDayOfWeek.nextDay;
        lastDayOfWeek = _lastDayOfWeek(firstDayOfWeek);
      }

      if (!lastDayOfWeek.isBefore(weekMaxDate)) {
        weeks.add(Week(firstDayOfWeek, lastDayOfWeek));
      }

      months.add(Month(weeks));

      months.removeWhere(
          (element) => maxDate.isBefore(element.weeks.first.firstDay));

      return months;
    }
  }

  static DateTime _lastDayOfWeek(DateTime firstDayOfWeek) {
    int daysInMonth = firstDayOfWeek.daysInMonth;

    if (firstDayOfWeek.day + 6 > daysInMonth) {
      return DateTime(firstDayOfWeek.year, firstDayOfWeek.month, daysInMonth);
    } else {
      return firstDayOfWeek.add(Duration(days: DateTime.saturday - (firstDayOfWeek.weekday == DateTime.sunday ? 0 : firstDayOfWeek.weekday)));
    }
  }

  static DateTime _findDayOfWeekInMonth(DateTime date, int dayOfWeek) {
    date = DateTime(date.year, date.month, date.day);

    if (date.weekday == dayOfWeek) {
      return date;
    } else {
      return date.subtract(Duration(days: date.weekday - dayOfWeek));
    }
  }

  static List<int> daysPerMonth(int year) => <int>[
        31,
        isLeapYear(year) ? 29 : 28,
        31,
        30,
        31,
        30,
        31,
        31,
        30,
        31,
        30,
        31,
      ];

  static bool isLeapYear(int year) {
    bool leapYear = false;

    bool leap = ((year % 100 == 0) && (year % 400 != 0));
    if (leap == true) {
      return false;
    } else if (year % 4 == 0) {
      return true;
    }

    return leapYear;
  }
}

extension DateUtilsExtensions on DateTime {
  bool get isLeapYear {
    bool leapYear = false;

    bool leap = ((year % 100 == 0) && (year % 400 != 0));
    if (leap == true) {
      return false;
    } else if (year % 4 == 0) {
      return true;
    }

    return leapYear;
  }

  int get daysInMonth => WeekHelper.daysPerMonth(year)[month - 1];

  DateTime toFirstDayOfNextMonth() => DateTime(
        year,
        month + 1,
      );

  DateTime get nextDay => DateTime(year, month, day + 1);

  bool isSameDayOrAfter(DateTime other) => isAfter(other) || isSameDay(other);

  bool isSameDayOrBefore(DateTime other) => isBefore(other) || isSameDay(other);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime removeTime() => DateTime(year, month, day);
}
