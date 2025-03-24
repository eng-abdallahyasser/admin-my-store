// edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_my_store/app/controllers/product_controller.dart';
import 'add_product_screen.dart'; // Reuse components from add screen

class EditProductScreen extends StatefulWidget {
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductController _controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final productId = Get.arguments as String;
    _controller.initializeProductForEditing(productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Reuse form components from AddProductScreen
                _buildCoverImageField(),
                _buildTextField('Title', "_controller."),
                // Add other form fields similarly
                ElevatedButton(
                  onPressed: () {
                    _controller.updateProduct;
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Reuse the same form components from AddProductScreen
  Widget _buildCoverImageField() {
    return GestureDetector(
      onTap: _pickCoverImage,
      child: Obx(() => Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: _controller.coverImage.value != null
                ? Image.memory(_controller.coverImage.value!)
                : const Icon(Icons.add_a_photo, size: 50),
          )),
    );
  }

  Future<void> _pickCoverImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      _controller.coverImage.value = bytes;
    }
  }

  Widget _buildTextField(String label, String initialValue) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? 'Required field' : null,
      onChanged: (value) {
        // Update corresponding controller property
      },
    );
  }
}
