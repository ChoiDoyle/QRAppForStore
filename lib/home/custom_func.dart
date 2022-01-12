class CustomFunc {
  String getTimestamp() {
    DateTime _now = DateTime.now();

    final _year = _now.year.toString();
    final year = _year.substring(2);
    final _month = '0' + _now.month.toString();
    final month = _month.substring(_month.length - 2);
    final _day = '0' + _now.day.toString();
    final day = _day.substring(_day.length - 2);
    final _hour = '0' + _now.hour.toString();
    final hour = _hour.substring(_hour.length - 2);
    final _min = '0' + _now.minute.toString();
    final min = _min.substring(_min.length - 2);
    final _sec = '0' + _now.second.toString();
    final sec = _sec.substring(_sec.length - 2);

    final _timestamp = '$year$month$day-$hour:$min:$sec';
    return _timestamp;
  }
}
