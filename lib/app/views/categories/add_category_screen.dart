import 'package:admin_my_store/app/controllers/category_controller.dart';
import 'package:admin_my_store/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCategoryScreen extends StatelessWidget {
  final CategoryController _controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  AddCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Category')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildWideLayout();
          } else {
            return _buildNarrowLayout();
          }
        },
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildImagePicker(),
            const SizedBox(height: 20),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            Obx(() => CustomButton(
              text: 'Save Category',
              onPressed: () {
                _controller.isLoading.value ? null : _submitForm();
              },
              isLoading: _controller.isLoading.value,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Center( // Center the content on wider screens.
      child: SizedBox(
        width: 600, // Limit the width for better readability on large screens
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Use stretch to fill the limited width
              children: [
                _buildImagePicker(),
                const SizedBox(height: 20),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 24),
                Obx(() => CustomButton(
                  text: 'Save Category',
                  onPressed: () {
                    _controller.isLoading.value ? null : _submitForm();
                  },
                  isLoading: _controller.isLoading.value,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _controller.pickCategoryImage,
      child: Obx(() => Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: _controller.categoryImage.value != null
            ? Image.memory(_controller.categoryImage.value!, fit: BoxFit.cover)
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 50),
                  Text('Tap to add image'),
                ],
              ),
      )),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _controller.nameController,
      decoration: InputDecoration(labelText: 'Category Name',border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),),
      validator: (value) => value!.isEmpty ? 'Required field' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _controller.descriptionController,
      decoration: InputDecoration(labelText: 'Description',border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),),
      maxLines: 3,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _controller.addCategory();
    }
  }
}

