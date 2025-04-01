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
      body: SingleChildScrollView(
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
                onPressed: (){_controller.isLoading.value ? null : _submitForm();},
                isLoading: _controller.isLoading.value,
              )),
            ],
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
      decoration: const InputDecoration(labelText: 'Category Name'),
      validator: (value) => value!.isEmpty ? 'Required field' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _controller.descriptionController,
      decoration: const InputDecoration(labelText: 'Description'),
      maxLines: 3,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _controller.addCategory();
    }
  }
}