import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationTokenModel {
  final Timestamp updatedAt;
  final String fcmToken;

  PushNotificationTokenModel({
    required this.updatedAt,
    required this.fcmToken,
  });

  // Factory constructor to create the model from Firestore data
  factory PushNotificationTokenModel.fromFirestore(Map<String, dynamic> data) =>
      PushNotificationTokenModel(
        updatedAt: data['updatedAt'] as Timestamp,
        fcmToken: data['fcmToken'] as String,
      );

  // Converts the model into a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'updatedAt': updatedAt,
      'fcmToken': fcmToken,
    };
  }

  @override
  String toString() {
    return 'PushNotificationTokenModel(updatedAt: ${updatedAt.toDate()}, fcmToken: $fcmToken)';
  }
}

class PushNotificationTokenDocument {
  final String documentId; // Firestore document ID
  final PushNotificationTokenModel data; // Associated data model

  PushNotificationTokenDocument({
    required this.documentId,
    required this.data,
  });

  // Factory constructor to create the document model from Firestore
  factory PushNotificationTokenDocument.fromFirestore(QueryDocumentSnapshot doc) {
    return PushNotificationTokenDocument(
      documentId: doc.id,
      data: PushNotificationTokenModel.fromFirestore(doc.data() as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return 'PushNotificationTokenDocument(documentId: $documentId, data: $data)';
  }
}
