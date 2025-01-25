import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hundy_p/firebase/model/push_noti_token_model.dart';

// Firestore Collection Reference with Converter
final tokensCollection = FirebaseFirestore.instance
    .collection('pushNotificationTokens')
    .withConverter<PushNotificationTokenModel>(
      fromFirestore: (snapshot, _) =>
          PushNotificationTokenModel.fromFirestore(snapshot.data()!),
      toFirestore: (PushNotificationTokenModel model, _) => model.toFirestore(),
    );

Future<List<PushNotificationTokenDocument>?> fetchAllUserTokens() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No authenticated user. Cannot store FCM token');
      return null;
    }

    final tokensCollection =
        FirebaseFirestore.instance.collection('pushNotificationTokens');

    final querySnapshot = await tokensCollection.get();

    // Map Firestore documents to PushNotificationTokenDocument
    final documents = querySnapshot.docs
        .map(PushNotificationTokenDocument.fromFirestore)
        .toList();

    print('PRINTING DOCS $documents');
    return documents;
  } catch (e) {
    print('Error fetching user tokens: $e');
    return null;
  }
}

Future<void> updateUserToken(String fcmToken) async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No authenticated user. Cannot store FCM token');
      return;
    }

    final userId = user.uid;

    final DocumentReference<PushNotificationTokenModel> tokenDocRef =
        tokensCollection.doc(userId);

    await tokenDocRef.set(PushNotificationTokenModel(
        updatedAt: Timestamp.now(),
        fcmToken: fcmToken,
        displayName: user.displayName ?? 'Distinguished Person'));
    print('FCM Token stored successfully for user: $userId');
  } catch (e) {
    print('Error storing FCM token: $e');
  }
}
