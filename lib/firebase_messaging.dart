import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> setupFirebaseMessaging() async {
  // Request notification permissions
  final notificationSettings =
      await FirebaseMessaging.instance.requestPermission(provisional: true);

  // Get APNS token (for iOS)
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
    print('APNS Token: $apnsToken');
  }

  // Fetch FCM token
  final vapidKey = dotenv.env['FIREBASE_VAPID_KEY'];

  if (vapidKey == null || vapidKey.isEmpty) {
    throw Exception("Valid key cannot be empty, please set as an env variable");
  }

  final fcmToken = await FirebaseMessaging.instance.getToken(
    vapidKey: vapidKey, // Add your VAPID public key for web
  );

  print('FCM Token: $fcmToken');

  // Listen for token updates
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('New FCM Token: $newToken');
    // Send the new token to your server, if necessary
  }).onError((err) {
    print('Error refreshing FCM token: $err');
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
}
