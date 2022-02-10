import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future removeSharedVar(String id) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.remove(id);
  }

  //페이지 이동
  void popPage(BuildContext context, page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  void startPage(BuildContext context, page) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => page,
        ));
  }
}

class NotificationAPi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false}) async {
    final _android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final _iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: _android, iOS: _iOS);

    await _notifications.initialize(settings,
        onSelectNotification: (payload) async {
      onNotifications.add(payload);
    });
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationDetails(),
        payload: payload,
      );
}
