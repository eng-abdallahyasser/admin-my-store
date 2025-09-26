import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/banner/banner_model.dart' as models;
import '../repo/banner_repository.dart';
import 'package:image_picker/image_picker.dart';

class BannerController extends GetxController {
  final BannerRepository _repo = Get.find<BannerRepository>();

  final RxList<models.Banner> banners = <models.Banner>[].obs;
  final RxBool isLoading = false.obs;

  // Form
  late TextEditingController titleController;
  late TextEditingController productIdController;
  late TextEditingController typeController;

  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  final Rx<String?> existingImageUrl = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    productIdController = TextEditingController();
    typeController = TextEditingController();
    loadBanners();
  }

  @override
  void onClose() {
    titleController.dispose();
    productIdController.dispose();
    typeController.dispose();
    super.onClose();
  }

  Future<void> loadBanners() async {
    try {
      isLoading(true);
      banners.value = await _repo.getAllBanners();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load banners: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<String> _uploadImage(Uint8List bytes) async {
    final ref = FirebaseStorage.instance
        .ref('banners/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }

  Future<void> addBanner() async {
    try {
      if (imageBytes.value == null) {
        Get.snackbar('Validation', 'Please select an image');
        return;
      }

      // Validate productId if banner type is product_linked_banner
      if (typeController.text.trim() == 'product_linked_banner' &&
          productIdController.text.trim().isEmpty) {
        Get.snackbar('Validation', 'Product ID is required for product linked banners');
        return;
      }

      isLoading(true);
      final imageUrl = await _uploadImage(imageBytes.value!);
      final banner = models.Banner(
        title: titleController.text.trim(),
        type: typeController.text.trim().isEmpty ? null : typeController.text.trim(),
        image: imageUrl,
        productId: productIdController.text.trim().isEmpty ? null : productIdController.text.trim(),
      );
      await _repo.addBanner(banner);
      await loadBanners();
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Banner added');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add banner: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> initializeForEdit(models.Banner banner) async {
    titleController.text = banner.title ?? '';
    productIdController.text = banner.productId ?? '';
    typeController.text = banner.type ?? '';
    existingImageUrl.value = banner.image;
    imageBytes.value = null;
  }

  Future<void> updateBanner(int id) async {
    try {
      isLoading(true);
      String? imageUrl = existingImageUrl.value;
      if (imageBytes.value != null) {
        imageUrl = await _uploadImage(imageBytes.value!);
      }
      final updated = models.Banner(
        id: id,
        title: titleController.text.trim(),
        type: typeController.text.trim().isEmpty ? null : typeController.text.trim(),
        productId: productIdController.text.trim().isEmpty ? null : productIdController.text.trim(),
        image: imageUrl,
      );
      await _repo.updateBanner(id, updated);
      await loadBanners();
      Get.back();
      Get.snackbar('Success', 'Banner updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update banner: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteBanner(int id) async {
    try {
      isLoading(true);
      await _repo.deleteBanner(id);
      banners.removeWhere((b) => b.id == id);
      Get.snackbar('Success', 'Banner deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete banner: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageBytes.value = await picked.readAsBytes();
    }
  }

  void clearForm() {
    titleController.clear();
    productIdController.clear();
    typeController.clear();
    imageBytes.value = null;
    existingImageUrl.value = null;
  }
}
