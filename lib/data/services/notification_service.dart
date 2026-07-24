import 'dart:convert';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message if needed
}

class NotificationService {
  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications;

  NotificationService({
    FirebaseMessaging? fcm,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _fcm = fcm ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  Future<void> initialize({
    required Function(String token) onTokenRefresh,
    required Function(Map<String, dynamic> data) onNotificationClick,
  }) async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Local Notification Android Channel Setup
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'chat_high_importance_channel',
        'Chat Notifications',
        description: 'Notifications for incoming chat messages',
        importance: Importance.high,
      );

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final Map<String, dynamic> data = jsonDecode(response.payload!);
              onNotificationClick(data);
            } catch (_) {}
          }
        },
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Get initial FCM Token
      String? token = await _fcm.getToken();
      if (token != null) {
        onTokenRefresh(token);
      }

      // Listen for token updates
      _fcm.onTokenRefresh.listen(onTokenRefresh);

      // Background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Initial message check (when app launched from terminated state via notification)
      _fcm.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          onNotificationClick(message.data);
        }
      });

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: jsonEncode(message.data),
          );
        }
      });

      // Handle message tap when app opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        onNotificationClick(message.data);
      });
    }
  }
}
