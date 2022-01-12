class CustomFunc {
  String getTimestamp() {
    DateTime _now = DateTime.now();
    final timestamp =
        '${_now.year}${_now.month}${_now.day}-${_now.hour}:${_now.minute}:${_now.second}';
    return timestamp;
  }
}
