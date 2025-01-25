import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../repository/push_noti_token_repository.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print("Full message: $message");
}

Future<void> setupFirebaseMessaging() async {
  // Request notification permissions
  final notificationSettings =
  await FirebaseMessaging.instance.requestPermission(provisional: true);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print(
      'User granted notification permission: ${settings.authorizationStatus}');

  // Get APNS token (for iOS)
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
    print('APNS Token: $apnsToken');
  } else {
    print('APNS Token is null');
  }

  // Listen for token updates
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await updateUserToken(newToken);
  }).onError((err) {
    print('Error refreshing FCM token: $err');
  });

  // Foreground messaging
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  // Background messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<String?> getFcmToken() async {
  // Fetch FCM token, web
  final vapidKey = dotenv.env['FIREBASE_VAPID_KEY'];

  if (vapidKey == null || vapidKey.isEmpty) {
    throw Exception("Valid key cannot be empty, please set as an env variable");
  }

  try {
    final fcmToken = await FirebaseMessaging.instance.getToken(
      vapidKey: vapidKey, // Add your VAPID public key for web
    );
    print("FCM Token: $fcmToken");
    return fcmToken;
  } catch (e) {
    print("Error fetching FCM token: $e");
  }
}

Future<void> reuploadToken() async {
  final token = await getFcmToken();
  if (token == null) {
    const message = 'Error!! Not good';
    print(message);
    throw FlutterError(message);
  }

  await updateUserToken(token);
}
