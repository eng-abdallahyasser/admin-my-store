import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackItem {
  final String? docId; // Firestore document ID (optional for convenience)
  final Timestamp? createdAt;
  final String message;
  final String type; // e.g., Suggestion, Bug, Complaint, Other
  final String userId;

  FeedbackItem({
    this.docId,
    required this.createdAt,
    required this.message,
    required this.type,
    required this.userId,
  });

  factory FeedbackItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    return FeedbackItem(
      docId: docId,
      createdAt: map['createdAt'] is Timestamp ? map['createdAt'] as Timestamp : null,
      message: (map['message'] ?? '') as String,
      type: (map['type'] ?? '') as String,
      userId: (map['userId'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'message': message,
      'type': type,
      'userId': userId,
    };
  }
}
