import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] ${message.notification?.title}');
}

final _localNotif = FlutterLocalNotificationsPlugin();

class NotificationService {
  static final _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // ── Local Notifications ───────────────────────────────────
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotif.initialize(
      const InitializationSettings(android: androidInit),
    );

    // สร้าง channel — เขียนแบบนี้เพื่อหลีก generic syntax error
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotif.resolvePlatformSpecificImplementation();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'flood_alerts',
        'การแจ้งเตือนน้ำท่วม',
        description: 'แจ้งเตือนสถานการณ์น้ำท่วมในชลบุรี',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    // ── FCM ───────────────────────────────────────────────────
    await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_bgHandler);

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] ${message.notification?.title}');
      _showLocal(message);
    });

    // ── Token ─────────────────────────────────────────────────
    final token = await _messaging.getToken();
    if (token != null) {
      debugPrint('[FCM Token] $token');
      await ApiService().saveNotifications({
        'push': true,
        'fcmToken': token,
        'levels': {'flood': true, 'risk': true, 'safe': false},
      });
    }

    _messaging.onTokenRefresh.listen((t) async {
      await ApiService().saveNotifications({
        'push': true, 'fcmToken': t,
        'levels': {'flood': true, 'risk': true, 'safe': false},
      });
    });
  }

  void _showLocal(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'flood_alerts',
          'การแจ้งเตือนน้ำท่วม',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF00D4FF),
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }

  Future<void> showTestNotification(String title, String body) async {
    await _localNotif.show(
      999, title, body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'flood_alerts',
          'การแจ้งเตือนน้ำท่วม',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFFEF4444),
          playSound: true,
        ),
      ),
    );
  }

  Future<String?> getToken() => _messaging.getToken();
}