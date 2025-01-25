import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/push_noti_token_model.dart';

Future<List<PushNotificationTokenDocument>?> fetchAllUserTokens() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No authenticated user. Cannot store FCM token');
      return null;
    }

    final userId = user.uid;

    final tokensCollection =
        FirebaseFirestore.instance.collection('pushNotificationTokens');

    final querySnapshot = await tokensCollection.get();

    // Map Firestore documents to PushNotificationTokenDocument
    final documents = querySnapshot.docs
        .map(PushNotificationTokenDocument.fromFirestore)
        .toList();

    final len = documents.length;

    print('PRINTING DOCS $len');
    documents.map((d) => {print(d)});
    return documents;

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

    // print('FCM Token stored successfully for user: $userId');
  } catch (e) {
    print('Error storing FCM token: $e');
    return null;
  }
}
