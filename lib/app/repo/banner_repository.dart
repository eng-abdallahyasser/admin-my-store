import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/banner/banner_model.dart' as models;

class BannerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _col => _firestore.collection('banners');

  Future<List<models.Banner>> getAllBanners() async {
    final snapshot = await _col.get();
    return snapshot.docs
        .map((doc) => models.Banner.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamBanners() {
    return _col.withConverter<Map<String, dynamic>>(
      fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
      toFirestore: (data, _) => data,
    ).snapshots();
  }

  Future<String> addBanner(models.Banner banner) async {
    final data = banner.toJson();
    final int numericId = DateTime.now().millisecondsSinceEpoch;
    await _col.add({
      ...data,
      'id': numericId,
      'createdAt': FieldValue.serverTimestamp(),
      'addedBy': _auth.currentUser?.uid,
    });
    return numericId.toString();
  }

  Future<void> updateBanner(int id, models.Banner banner) async {
    final snap = await _col.where('id', isEqualTo: id).limit(1).get();
    if (snap.docs.isEmpty) throw Exception('Banner not found');
    await snap.docs.first.reference.update({
      ...banner.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBanner(int id) async {
    final snap = await _col.where('id', isEqualTo: id).limit(1).get();
    if (snap.docs.isEmpty) throw Exception('Banner not found');
    await snap.docs.first.reference.delete();
  }

  Future<models.Banner> getBannerById(int id) async {
    final snap = await _col.where('id', isEqualTo: id).limit(1).get();
    if (snap.docs.isEmpty) throw Exception('Banner not found');
    final data = snap.docs.first.data() as Map<String, dynamic>;
    return models.Banner.fromJson(data);
  }
}
