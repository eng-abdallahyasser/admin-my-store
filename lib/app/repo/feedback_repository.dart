import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/feedback.dart';

class FeedbackRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('feedback').withConverter<Map<String, dynamic>>(
            fromFirestore: (snap, _) => (snap.data() ?? <String, dynamic>{}),
            toFirestore: (data, _) => data,
          );

  Future<List<FeedbackItem>> getAll() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((doc) => FeedbackItem.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  Stream<List<FeedbackItem>> streamAll() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((doc) => FeedbackItem.fromMap(doc.data(), docId: doc.id))
            .toList());
  }

  Future<void> add(FeedbackItem item) async {
    await _col.add(item.toMap());
  }

  Future<void> deleteByDocId(String docId) async {
    await _col.doc(docId).delete();
  }
}
