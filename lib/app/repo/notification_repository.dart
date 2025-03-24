import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationRepository {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }
}