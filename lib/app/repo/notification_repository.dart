import 'dart:async';
import 'dart:developer' as developer;
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:admin_my_store/app/models/app_notification.dart';
import 'package:admin_my_store/app/utils/http_utils.dart';

/// Base URL for the external notification endpoint
String get _notificationEndpoint {
  if (kIsWeb) {
    // For web, use the environment variable from the build process
    return const String.fromEnvironment(
      'NOTIFICATION_ENDPOINT',
      defaultValue: 'https://fcm-worker.wesaya-admin.workers.dev/',
    );
  }
  // For mobile/desktop, use dotenv
  return 
      'https://fcm-worker.wesaya-admin.workers.dev/';
}

/// API key required by the external notification endpoint
String get _notificationApiKey {
  if (kIsWeb) {
    // For web, use the environment variable from the build process
    return const String.fromEnvironment(
      'NOTIFICATION_API_KEY',
      defaultValue: '',
    );
  }
  // For mobile/desktop, use dotenv
  return 'NOTIFICATION_API_KEY';
}

class NotificationRepository {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  Future<void> saveAdminToken(String userId, String token) async {
    await _db.collection('admins').doc(userId).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> sendToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? type,
    String? userId, // Add userId parameter to identify the target user
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      data: data ?? {},
      timestamp: DateTime.now(),
    );
    log('user id: $userId');
    // Save to specific user's notifications if userId is provided
    if (userId != null && userId.isNotEmpty) {
      await _saveUserNotification(userId, notification);
    }

    await _postNotification(
      payload: {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image': imageUrl,
        },
        if (data != null && data.isNotEmpty) 'data': _sanitizeData(data),
        if (type != null && type.isNotEmpty) 'type': type,
      },
    );
  }

  Future<void> sendToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      data: data ?? {},
      timestamp: DateTime.now(),
      read: true,
    );

    // Save to all_users_notifications if the topic is 'all-users'
    if (topic == 'all-users') {
      await _saveAllUsersNotification(notification);
    }

    await _postNotification(
      payload: {
        'topic': topic,
        'notification': {
          'title': title,
          'body': body,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image': imageUrl,
        },
        if (data != null && data.isNotEmpty) 'data': _sanitizeData(data),
      },
    );
  }

  Future<void> saveAdminNotification(
    String adminId,
    AppNotification notification,
  ) async {
    await _db
        .collection('admins')
        .doc(adminId)
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }

  // Make sure this is an async function to use 'await'
  Future<String?> getUserIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // Return null if no user is signed in
      if (user == null) {
        log('No user is currently signed in.');
        return null;
      }

      // Force a refresh of the token by passing true
      final idToken = await user.getIdToken();

      // Send this token to your backend
      log('User ID Token: $idToken');
      return idToken;
    } catch (e) {
      // Handle any errors
      log('Error getting ID token: $e');
      return null;
    }
  }

  Future<void> _postNotification({
    required Map<String, dynamic> payload,
  }) async {
    if (_notificationEndpoint.isEmpty) {
      throw Exception(
        'Notification endpoint not configured. Please set NOTIFICATION_ENDPOINT environment variable.',
      );
    }

    // Sanitize the payload to remove null values
    final sanitizedPayload = _sanitizePayload(payload);

    // Ensure the payload has the required structure
    if (!sanitizedPayload.containsKey('notification')) {
      sanitizedPayload['notification'] = {};
    }
    if (!sanitizedPayload.containsKey('data')) {
      sanitizedPayload['data'] = {};
    }

    try {
      // Prepare headers
      final headers = <String, String>{};

      // Add API key to headers if available
      final apiKey = _notificationApiKey;
      if (apiKey.isNotEmpty) {
        headers['x-api-key'] = apiKey;
      }
      
      

      developer.log(
        'Sending notification to $_notificationEndpoint',
        name: 'NotificationRepository',
      );
      developer.log(
        'Payload: $sanitizedPayload',
        name: 'NotificationRepository',
      );

      // Use our HTTP utility that handles CORS
      final response = await HttpUtils.postWithCORS(
        _notificationEndpoint,
        headers: headers,
        body: sanitizedPayload,
      );

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'NotificationRepository',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log(
          'Notification sent successfully',
          name: 'NotificationRepository',
        );
        return;
      }

      // Handle specific error status codes
      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please check your JWT token.');
      } else if (response.statusCode == 403) {
        throw Exception(
          'Permission denied. You may not have admin privileges.',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'Notification endpoint not found. Please check the URL.',
        );
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
          'Failed to send notification (${response.statusCode}): ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      final error =
          'Failed to connect to the notification service. ${e.message}';
      developer.log(error, name: 'NotificationRepository');
      throw Exception(error);
    } on TimeoutException {
      const error =
          'Request timed out. Please check your internet connection and try again.';
      developer.log(error, name: 'NotificationRepository');
      throw Exception(error);
    } on FormatException catch (e) {
      final error = 'Invalid response format from server. ${e.message}';
      developer.log(error, name: 'NotificationRepository');
      throw Exception(error);
    } catch (e, stackTrace) {
      final error = 'Unexpected error sending notification: $e';
      developer.log(
        error,
        error: e,
        stackTrace: stackTrace,
        name: 'NotificationRepository',
      );
      rethrow;
    }
  }

  Map<String, dynamic> _sanitizePayload(Map<String, dynamic> payload) {
    final sanitized = <String, dynamic>{};
    for (final entry in payload.entries) {
      if (entry.value != null) {
        if (entry.value is Map<String, dynamic>) {
          sanitized[entry.key] = _sanitizePayload(entry.value);
        } else if (entry.value is List) {
          sanitized[entry.key] = entry.value;
        } else {
          sanitized[entry.key] = entry.value;
        }
      }
    }
    return sanitized;
  }

  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.value != null) {
        sanitized[entry.key] = entry.value.toString();
      }
    }
    return sanitized;
  }

  /// Saves a notification to the all_users_notifications collection
  Future<void> _saveAllUsersNotification(AppNotification notification) async {
    try {
      await _db
          .collection('all_users_notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      developer.log(
        'Error saving notification to all_users_notifications: $e',
        name: 'NotificationRepository',
        error: e,
      );
      rethrow;
    }
  }

  /// Saves a notification to a specific user's notifications subcollection
  Future<void> _saveUserNotification(String userId, AppNotification notification) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      developer.log(
        'Error saving notification to user $userId: $e',
        name: 'NotificationRepository',
        error: e,
      );
      rethrow;
    }
  }
}
