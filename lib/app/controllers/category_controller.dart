import 'dart:typed_data';
import 'package:admin_my_store/app/models/category.dart';
import 'package:admin_my_store/app/repo/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class CategoryController extends GetxController {
  final CategoryRepository _repository = Get.find();
  final RxList<Category> categories = <Category>[].obs;
  final Rx<Uint8List?> categoryImage = Rx<Uint8List?>(null);
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    loadCategories();
    super.onInit();
  }

  Future<void> loadCategories() async {
    try {
      isLoading(true);
      categories.value = await _repository.getAllCategories();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addCategory() async {
    try {
      isLoading(true);
      String? imageUrl;
      
      if (categoryImage.value != null) {
        imageUrl = await _uploadImage(categoryImage.value!);
      }

      final newCategory = Category(
        id: '',
        name: nameController.text,
        description: descriptionController.text,
        image: imageUrl ?? '',
      );

      await _repository.addCategory(newCategory);
      categories.add(newCategory);
      Get.back();
      Get.snackbar('Success', 'Category added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add category');
    } finally {
      clearForm();
      isLoading(false);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      isLoading(true);
      await _repository.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      Get.snackbar('Success', 'Category deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category');
    } finally {
      isLoading(false);
    }
  }

  Future<String> _uploadImage(Uint8List image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('category_images/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putData(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed');
    }
  }

  Future<void> pickCategoryImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      categoryImage.value = bytes;
    }
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    categoryImage.value = null;
  }
}