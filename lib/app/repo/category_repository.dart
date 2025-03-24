import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCategory(Category category) async {
    await _firestore.collection('categories').doc(category.name).set({
      'description': category.description,
      'image': category.image,
    });
  }
}