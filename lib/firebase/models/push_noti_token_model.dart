import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationTokenModel {
  final String userId;
  final Timestamp updatedAt;
  final String token;

  PushNotificationTokenModel({
    required this.userId,
    required this.updatedAt,
    required this.token,
  });

  // Factory constructor to create the model from Firestore data
  factory PushNotificationTokenModel.fromFirestore(Map<String, dynamic> data) => PushNotificationTokenModel(
      userId: data['userId'] as String,
      updatedAt: (data['updatedAt'] as Timestamp),
      token: data['token'] as String,
    );
}

class PushNotificationTokenDocument {
  final String documentId; // Document ID, to access the data
  final PushNotificationTokenModel data; // The data associated with the document

  PushNotificationTokenDocument({
    required this.documentId,
    required this.data,
  });

  // Factory constructor to create the document model from Firestore
  factory PushNotificationTokenDocument.fromFirestore(
      QueryDocumentSnapshot doc) {
    return PushNotificationTokenDocument(
      documentId: doc.id, // Firestore document ID
      data: PushNotificationTokenModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
      ),
    );
  }
}
