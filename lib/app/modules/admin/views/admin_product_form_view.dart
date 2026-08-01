import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_product_form_controller.dart';

class AdminProductFormView extends GetView<AdminProductFormController> {
  const AdminProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Obx(() => Text(
          controller.isEditMode.value ? 'Edit Produk' : 'Tambah Produk',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: controller.nameController,
              label: 'Nama Produk',
              validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.brandController,
              label: 'Brand',
              validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            _buildDropdownField(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.priceController,
              label: 'Harga',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Wajib diisi';
                if (double.tryParse(value) == null) return 'Harus berupa angka';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.stockController,
              label: 'Stok',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Wajib diisi';
                if (int.tryParse(value) == null) return 'Harus berupa angka';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.imageUrlController,
              label: 'Image URL',
              validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.descriptionController,
              label: 'Deskripsi',
              maxLines: 4,
              validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 32),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Simpan Produk',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF3B30)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedCategory.value,
      dropdownColor: const Color(0xFF2C2C2E),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Kategori',
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: controller.categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) controller.selectedCategory.value = value;
      },
    ));
  }
}
