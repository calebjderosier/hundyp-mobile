import 'package:firebase_messaging/firebase_messaging.dart';

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
  final fcmToken = await FirebaseMessaging.instance.getToken(
    vapidKey: "", // Add your VAPID public key for web
  );
  print('FCM Token: $fcmToken');

  // Listen for token updates
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('New FCM Token: $newToken');
    // Send the new token to your server, if necessary
  }).onError((err) {
    print('Error refreshing FCM token: $err');
  });
}
