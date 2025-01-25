import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  storeFcmToken('mr sir', fcmToken);

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

Future<void> storeFcmToken(String userId, String? token) async {
  if (token == null) {
    // todo - this shouldn't ever happen. fix
    print('Token invalid. Cannot store');
    return;
  }

  try {
    final tokensCollection =
        FirebaseFirestore.instance.collection('pushNotificationTokens');

    // Store or update the token for the user
    // await tokensCollection.doc(userId).set({
    //   'fcmToken': token,
    //   'updatedAt': FieldValue.serverTimestamp(),
    // });

    final querySnapshot = await tokensCollection.get();

    final docs = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();

    print(docs.first);

    print("FCM Token stored successfully for user: $userId");
  } catch (e) {
    print("Error storing FCM token: $e");
  }
}
