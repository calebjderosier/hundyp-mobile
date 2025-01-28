import 'dart:html' as html;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hundy_p/firebase/repository/push_noti_token_repository.dart';
import 'package:hundy_p/state_handlers/snackbar_handler.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print("Full message: $message");
}

Future<void> setupFirebaseMessaging() async {
  // ask for notification permission
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Get APNS token (for iOS)
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
    print('APNS Token: $apnsToken');
  } else {
    print('APNS Token is null');
  }

  await uploadFcmToken();
  setupMessagingListeners();
}

Future<String?> getFcmToken() async {
  // Fetch FCM token, web
  final vapidKey = dotenv.env['FIREBASE_VAPID_KEY'];

  if (vapidKey == null || vapidKey.isEmpty) {
    throw Exception("Vapid key cannot be empty, please set as an env variable");
  }

  try {
    final fcmToken = await FirebaseMessaging.instance.getToken(
      vapidKey: vapidKey, // Add your VAPID public key for web
    );
    return fcmToken;
  } catch (e) {
    print("Error fetching FCM token: $e");
    return null;
  }

}

Future<void> uploadFcmToken() async {
  final token = await getFcmToken();
  if (token == null) {
    const message = 'Failed to get token! Prompt for user permissions';
    print(message);
    throw FlutterError(message);
  }

  await updateUserToken(token);
}

void setupMessagingListeners() {
  // Listen for token updates
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await updateUserToken(newToken);
  }).onError((err) {
    print('Error refreshing FCM token: $err');
  });

  // Foreground messaging
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      SnackBarHandler().showSnackBar(
        message:
        '${message.notification!.title}: ${message.notification!.body}',
      );
    }
  });

  // Background messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

// Define an enum to represent the notification permission status
enum NotificationPermissionStatus {
  granted,
  denied,
  notGranted,
}

NotificationPermissionStatus getNotificationPermission() {
  final permission = html.Notification.permission;

  if (permission == 'granted') {
    return NotificationPermissionStatus.granted;
  } else if (permission == 'denied') {
    return NotificationPermissionStatus.denied;
  } else {
    return NotificationPermissionStatus.notGranted;
  }

}

Future<NotificationPermissionStatus> requestNotificationPermission() async {
  if (!kIsWeb) return NotificationPermissionStatus.granted;

  // Check the current permission status
  final permission = html.Notification.permission;

  if (permission == 'granted') {
    return NotificationPermissionStatus.granted;
  } else if (permission == 'denied') {
    return NotificationPermissionStatus.denied;
  } else {
    // Prompt the user for permission
    return await explicitlyRequestNotiPermission();
  }
}

Future<NotificationPermissionStatus> explicitlyRequestNotiPermission() async {
  if (!kIsWeb) return NotificationPermissionStatus.granted;

  // Prompt the user for permission
  final result = await html.Notification.requestPermission();
  if (result == 'granted') {
    return NotificationPermissionStatus.granted;
  } else if (result == 'denied') {
    return NotificationPermissionStatus.denied;
  } else {
    return NotificationPermissionStatus.notGranted;
  }
}
