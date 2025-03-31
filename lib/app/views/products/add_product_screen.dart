import 'package:admin_my_store/app/models/variant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_my_store/app/controllers/product_controller.dart';
import 'package:admin_my_store/app/models/option.dart';

class AddProductScreen extends StatelessWidget {
  AddProductScreen({super.key});

  final ProductController _controller = Get.find();

  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Column(
            children: [
              _buildCoverImageField(),
              _buildTextField(
                'Title',
                (value) => _controller.titleController.text = value,
              ),
              _buildTextField(
                'Description',
                (value) => _controller.descriptionController.text = value,
              ),
              _buildPriceFields(),
              _buildCategoryDropdown(),
              _buildColorSelection(),
              _buildOptionsSection(),
              _buildImageUpload(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImageField() {
    return GestureDetector(
      onTap: _pickCoverImage,
      child: Obx(
        () => Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child:
              _controller.coverImage.value != null
                  ? Image.memory(_controller.coverImage.value!)
                  : const Icon(Icons.add_a_photo, size: 50),
        ),
      ),
    );
  }

  Future<void> _pickCoverImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      _controller.coverImage.value = bytes;
    }
  }

  Widget _buildTextField(String label, Function(String) onSaved) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? 'Required field' : null,
      onSaved: (value) => onSaved(value!),
    );
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _controller.priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Required field' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _controller.oldPriceController,
            decoration: const InputDecoration(labelText: 'Old Price'),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Obx(
      () => DropdownButtonFormField<String>(
        items:
            _controller.categories
                .map(
                  (category) => DropdownMenuItem(
                    value: category.name,
                    child: Text(category.name),
                  ),
                )
                .toList(),
        onChanged: (value) => _controller.selectedCategory.value = value!,
        decoration: const InputDecoration(labelText: 'Category'),
        validator: (value) => value == null ? 'Please select a category' : null,
      ),
    );
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Colors', style: TextStyle(fontSize: 16)),
        Wrap(
          spacing: 8,
          children:
              Colors.primaries.map((color) {
                return GestureDetector(
                  onTap: () => _controller.toggleColor(color),
                  child: Obx(
                    () => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        border:
                            _controller.selectedColors.contains(color)
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text('Product Options', style: TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed:
                  () => _controller.addOption(
                    Option(
                      min: 1,
                      max: 1,
                      optionName: 'option ${_controller.options.length}',
                      choosedVariant: [],
                      variants: [],
                    ),
                  ),
            ),
          ],
        ),
        Obx(
          () => Column(
            children:
                _controller.options
                    .map((option) => _buildOptionForm(option))
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionForm(Option option) {
    final TextEditingController variantNameController = TextEditingController();
    final TextEditingController variantPriceController =
        TextEditingController();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Option Name'),
                    initialValue: "option ${_controller.options.length}",
                    onChanged: (value) => option.optionName = value,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _controller.options.remove(option),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Min'),
                    keyboardType: TextInputType.number,
                    initialValue: option.min.toString(),
                    onChanged: (value) => option.min = int.tryParse(value) ?? 0,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Max'),
                    keyboardType: TextInputType.number,
                    initialValue: option.max.toString(),
                    onChanged: (value) => option.max = int.tryParse(value) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Variant Creation UI
            const Text(
              'Variants',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Column(
                children: [
                  ...option.variants.map(
                    (variant) => ListTile(
                      title: Text(variant.name),
                      subtitle: Text('\$${variant.price.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => _controller.removeVariant(
                              variant,
                              option.optionName,
                            ),
                      ),
                    ),
                  ),
                  if (_controller.variants.isNotEmpty) const Divider(),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: variantNameController,
                    decoration: const InputDecoration(
                      labelText: 'Variant Name',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: variantPriceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (variantNameController.text.isNotEmpty &&
                        variantPriceController.text.isNotEmpty) {
                      _controller.addVariants(
                        Variant(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          name: variantNameController.text,
                          price:
                              double.tryParse(variantPriceController.text) ??
                              0.0,
                        ),
                        option.optionName,
                      );
                      variantNameController.clear();
                      variantPriceController.clear();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return Column(
      children: [
        const Text('Additional Images', style: TextStyle(fontSize: 16)),
        Obx(
          () => Wrap(
            spacing: 8,
            children:
                _controller.additionalImages
                    .map(
                      (image) => Stack(
                        children: [
                          Image.memory(image, width: 80, height: 80),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _controller.removeImage(image);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          ),
        ),
        TextButton(
          onPressed: _pickAdditionalImages,
          child: const Text('Add Images'),
        ),
      ],
    );
  }

  Future<void> _pickAdditionalImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    for (var file in pickedFiles) {
      final bytes = await file.readAsBytes();
      _controller.additionalImages.add(bytes);
    }
  }

  void _submitForm() {
    _controller.addProduct();
    Get.back();
  }
}
