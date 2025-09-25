import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:admin_my_store/app/repo/notification_repository.dart';
import 'package:admin_my_store/app/repo/auth_repository.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';

class NotificationService {
  NotificationService();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _defaultAndroidChannel = AndroidNotificationChannel(
    'admin_my_store_default',
    'General Notifications',
    description: 'Default channel for general notifications',
    importance: Importance.high,
  );

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Request permissions (iOS/macOS/web)
    try {
      await _messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } catch (e, s) {
      developer.log('FCM permission request failed', error: e, stackTrace: s);
    }

    // Initialize local notifications (not supported on Web)
    if (!kIsWeb) {
      const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
      const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _local.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            try {
              final data = jsonDecode(payload) as Map<String, dynamic>;
              _navigateFromData(data);
            } catch (_) {}
          }
        },
      );

      // Create default channel on Android
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_defaultAndroidChannel);
    }

    // Register listeners
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateFromData(message.data);
    });

    // Handle initial message when app is launched from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _navigateFromData(initialMessage.data);
    }

    // Fetch and persist FCM token for the signed-in admin
    try {
      String? token;
      if (kIsWeb) {
        // Optional: provide your Web Push certificates key pair (VAPID public key) for web
        // You can inject it via --dart-define=FCM_VAPID_KEY=... and read from const String.fromEnvironment
        const vapidKey = String.fromEnvironment('FCM_VAPID_KEY', defaultValue: '');
        token = vapidKey.isNotEmpty
            ? await _messaging.getToken(vapidKey: vapidKey)
            : await _messaging.getToken();
      } else {
        token = await _messaging.getToken();
      }
      await _saveToken(token);
    } catch (e, s) {
      // Do not crash app if token retrieval fails on web
      developer.log('FCM getToken failed', error: e, stackTrace: s);
    }

    _messaging.onTokenRefresh.listen(_saveToken);

    _initialized = true;
  }

  Future<void> _saveToken(String? token) async {
    if (token == null) return;
    final authRepo = Get.find<AuthRepository>();
    final user = authRepo.currentUser;
    if (user == null) return;

    await Get.find<NotificationRepository>().saveAdminToken(user.uid, token);
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString() ?? 'Notification';
    final body = notification?.body ?? message.data['body']?.toString() ?? '';
    if (kIsWeb) {
      // Fallback to in-app banner on web; OS-level notifications are handled by the browser/SW for background
      try {
        Get.snackbar(title, body, snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 3));
      } catch (_) {}
      return;
    }

    _local.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultAndroidChannel.id,
          _defaultAndroidChannel.name,
          channelDescription: _defaultAndroidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: notification?.android?.smallIcon ?? '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final route = data['route']?.toString();
    if (route == null || route.isEmpty) return;

    if (route == Routes.orderDetails && data['orderId'] != null) {
      Get.toNamed(Routes.orderDetails, arguments: data['orderId']);
    } else {
      Get.toNamed(route, arguments: data);
    }
  }
}
