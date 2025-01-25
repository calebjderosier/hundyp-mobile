import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase/push_noti_token_service.dart';

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

  print('User granted notification permission: ${settings.authorizationStatus}');

  // Get APNS token (for iOS)
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
    print('APNS Token: $apnsToken');
  } else {
    print('APNS Token is null');
  }

  final fcmToken = await getFcmToken();
  storeFcmToken(fcmToken);

  // Listen for token updates
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('New FCM Token: $newToken');
    // Send the new token to your server, if necessary
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
    return null;
  }
}

Future<void> storeFcmToken(String? token) async {
  if (token == null) {
    print('Token invalid. Cannot store.');
    return;
  }

  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No authenticated user. Cannot store FCM token');
      return;
    }

    final userId = user.uid;

    final docs = await fetchAllUserTokens();

    // // Reference to the user's document in Firestore
    // final tokenDocRef = FirebaseFirestore.instance
    //     .collection('pushNotificationTokens')
    //     .doc(userId);
    //
    // // Write or update the token
    // await tokenDocRef.set({
    //   'userId': userId,
    //   'fcmToken': token,
    //   'updatedAt': FieldValue.serverTimestamp(),
    // });

    print('FCM Token stored successfully for user: $userId');
  } catch (e) {
    print('Error storing FCM token: $e');
  }
}
