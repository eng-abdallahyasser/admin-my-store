// product_controller.dart
import 'dart:developer';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_my_store/app/models/category.dart';
import 'package:admin_my_store/app/models/option.dart';
import 'package:admin_my_store/app/models/product.dart';
import 'package:admin_my_store/app/repo/product_repository.dart';


class ProductController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final Rx<Uint8List?> coverImage = Rx<Uint8List?>(null);
  final RxList<Uint8List> additionalImages = <Uint8List>[].obs;
  final RxBool isLoading = false.obs;
  RxString selectedCategory = ''.obs;
  final RxList<Color> selectedColors = <Color>[].obs;
  final RxList<Option> options = <Option>[].obs;

  // Form fields
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController oldPriceController;

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController();
    oldPriceController = TextEditingController();
    loadProducts();
    loadCategories();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    oldPriceController.dispose();
    super.onClose();
  }

  Future<void> loadProducts() async {
    try {
      isLoading(true);
      products.value = await _productRepository.getAllProducts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadCategories() async {
    try {
      final result = await _productRepository.getCategories();
      categories.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories: ${e.toString()}');
    }
  }

  Future<void> addProduct() async {
    try {
      isLoading(true);
      
      // Upload images
      final coverUrl = await _uploadImage(coverImage.value!, 'cover');
      final List<String> additionalUrls = [];
      for (var image in additionalImages) {
        final url = await _uploadImage(image, 'gallery');
        additionalUrls.add(url);
      }

      // Create new product
      final newProduct = Product(
        id: '',
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory.value,
        price: double.parse(priceController.text),
        oldPrice: double.tryParse(oldPriceController.text)!,
        imagesUrl: additionalUrls,
        colors: selectedColors,
        options: options,
        // Initialize other fields
        quantity: 0,
        rating: 0,
        isInitialezed: false,
        isPopular: false,
        favouritecount: 0,
        optionsNames: options.map((o) => o.optionName).toList(),
      );

      // Save to Firestore
      final productId = await _productRepository.addProduct(newProduct);
      newProduct.id = productId;
      products.add(newProduct);
      
      Get.back();
      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: ${e.toString()}');
    } finally {
      clearForm();
      isLoading(false);
    }
  }

  Future<void> updateProduct(String productId) async {
    try {
      isLoading(true);
      // Similar to addProduct but with update logic
      // Handle image updates and Firestore update
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      isLoading(true);
      await _productRepository.deleteProduct(productId);
      products.removeWhere((p) => p.id == productId);
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<String> _uploadImage(Uint8List image, String path) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('products/$path/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putData(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed: ${e.toString()}');
    }
  }

  void pickCoverImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      coverImage.value = bytes;
    }
  }

  void pickAdditionalImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    for (var file in pickedFiles) {
      final bytes = await file.readAsBytes();
      additionalImages.add(bytes);
    }
    }

  void addOption(Option option) {
    options.add(option);
  }

  void removeOption(int index) {
    options.removeAt(index);
  }

  void toggleColor(Color color) {
    if (selectedColors.contains(color)) {
      selectedColors.remove(color);
    } else {
      selectedColors.add(color);
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    oldPriceController.clear();
    coverImage.value = null;
    additionalImages.clear();
    selectedColors.clear();
    options.clear();
    selectedCategory.value = '';
  }

  Future<void> initializeProductForEditing(String productId) async {
    try {
      isLoading(true);
      final product = await _productRepository.getProductById(productId);
      // Populate form fields with product data
      titleController.text = product.title;
      descriptionController.text = product.description;
      priceController.text = product.price.toString();
      oldPriceController.text = product.oldPrice?.toString() ?? '';
      selectedCategory.value = product.category;
      selectedColors.value = product.colors;
      options.value = product.options;
      // Handle image loading if needed
    } catch (e) {
      Get.snackbar('Error', 'Failed to load product: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void removeImage(Uint8List image) {}
  
}