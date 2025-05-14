// edit_product_screen.dart
import 'package:admin_my_store/app/models/option.dart';
import 'package:admin_my_store/app/models/variant.dart';
import 'package:admin_my_store/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_my_store/app/controllers/product_controller.dart';

class EditProductScreen extends StatefulWidget {
  final productId = Get.arguments as String;
  final _picker = ImagePicker();

  EditProductScreen({super.key});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductController _controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initializeProductForEditing(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 600) {
              return _buildWideLayout(context);
            } else {
              return _buildNarrowLayout(context);
            }
          },
        );
      }),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCoverImageField(),
            _buildTextField(
              'Title',
              _controller.titleController,
              (value) => _controller.titleController.text = value,
            ),
            _buildTextField(
              'Description',
              _controller.descriptionController,
              (value) => _controller.descriptionController.text = value,
            ),
            _buildPriceFields(),
            _buildCategoryDropdown(),
            _buildColorSelection(),
            _buildOptionsSection(),
            _buildImageUpload(),
            const SizedBox(height: 20),
            Obx(
              () => CustomButton(
                text: 'Save Changes',
                onPressed: () {
                  _controller.isLoading.value ? null : _updateProduct();
                },
                isLoading: _controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverImageFieldWide(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildTextField(
                        'Title',
                        _controller.titleController,
                        (value) => _controller.titleController.text = value,
                      ),
                      _buildTextField(
                        'Description',
                        _controller.descriptionController,
                        (value) =>
                            _controller.descriptionController.text = value,
                      ),
                      _buildPriceFields(),
                      _buildCategoryDropdown(),
                      _buildColorSelection(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [_buildOptionsSection(), _buildImageUpload()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(
              () => Center(
                child: CustomButton(
                  text: 'Save Changes',
                  onPressed: () {
                    _controller.isLoading.value ? null : _updateProduct();
                  },
                  isLoading: _controller.isLoading.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProduct() {
    _controller.updateProduct(widget.productId);
    Get.back();
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
                  ? Image.memory(
                    _controller.coverImage.value!,
                    fit: BoxFit.cover,
                  )
                  : const Icon(Icons.add_a_photo, size: 50),
        ),
      ),
    );
  }

  Widget _buildCoverImageFieldWide() {
    return Row(
      children: [
        GestureDetector(
          onTap: _pickCoverImage,
          child: Obx(
            () => Container(
              height: 200,
              width: 300,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child:
                  _controller.coverImage.value != null
                      ? Image.memory(
                        _controller.coverImage.value!,
                        fit: BoxFit.cover,
                      )
                      : const Icon(Icons.add_a_photo, size: 50),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(child: SizedBox()), // Spacer
      ],
    );
  }

  Future<void> _pickCoverImage() async {
    final pickedFile = await widget._picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      _controller.coverImage.value = bytes;
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    Function(String) onSaved,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: label,border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),),
        controller: controller,
        validator: (value) => value!.isEmpty ? 'Required field' : null,
        onSaved: (value) => onSaved(value!),
      ),
    );
  }

  Widget _buildPriceFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller.priceController,
              decoration:  InputDecoration(labelText: 'Price',border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _controller.oldPriceController,
              decoration:  InputDecoration(labelText: 'Old Price',border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(
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
          decoration: InputDecoration(
            labelText:
                (_controller.selectedCategory.value == "")
                    ? 'Category'
                    : _controller.selectedCategory.value,
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
          ),
          validator:
              (value) => value == null ? 'Please select a category' : null,
        ),
      ),
    );
  }

  Widget _buildColorSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Colors', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Product Options', style: TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed:
                    () => _controller.addOption(
                      Option(
                        min: 1,
                        max: 1,
                        optionName: 'option ${_controller.options.length + 1}',
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
      ),
    );
  }

  Widget _buildOptionForm(Option option) {
    final TextEditingController variantNameController = TextEditingController();
    final TextEditingController variantPriceController =
        TextEditingController();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Option Name',border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),),
                    initialValue: option.optionName,
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
                    decoration:  InputDecoration(labelText: 'Min',border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),),
                    keyboardType: TextInputType.number,
                    initialValue: option.min.toString(),
                    onChanged: (value) => option.min = int.tryParse(value) ?? 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration:  InputDecoration(labelText: 'Max',border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),),
                    keyboardType: TextInputType.number,
                    initialValue: option.max.toString(),
                    onChanged: (value) => option.max = int.tryParse(value) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                    decoration:  InputDecoration(
                      labelText: 'Variant Name',border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: variantPriceController,
                    decoration:  InputDecoration(labelText: 'Price',border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),),
                    keyboardType: const TextInputType.numberWithOptions(
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Additional Images', style: TextStyle(fontSize: 16)),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _controller.additionalImages
                      .map(
                        (image) => SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            children: [
                              Image.memory(
                                image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => _controller.removeImage(image),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
      ),
    );
  }

  Future<void> _pickAdditionalImages() async {
    final pickedFiles = await widget._picker.pickMultiImage();
    for (var file in pickedFiles) {
      final bytes = await file.readAsBytes();
      _controller.additionalImages.add(bytes);
    }
  }
}
