import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_dashboard_controller.dart';
import 'package:prolens_digital/app/modules/home/controllers/notification_controller.dart';

class AdminProductFormController extends GetxController {
  final supabase = Supabase.instance.client;

  final formKey = GlobalKey<FormState>();
  
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController(text: '10');
  final imageUrlController = TextEditingController();
  final descriptionController = TextEditingController();
  
  var selectedCategory = 'Kamera DSLR'.obs;
  final categories = ['Kamera DSLR', 'Mirrorless', 'Lensa', 'Aksesoris'];

  var isLoading = false.obs;
  var isEditMode = false.obs;
  String? productId;
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      isEditMode.value = true;
      productId = args['id'];
      nameController.text = args['name'] ?? '';
      brandController.text = args['brand'] ?? '';
      priceController.text = (args['price'] ?? 0).toString();
      stockController.text = (args['stock'] ?? 10).toString();
      imageUrlController.text = args['image_url'] ?? '';
      descriptionController.text = args['description'] ?? '';
      if (categories.contains(args['category'])) {
        selectedCategory.value = args['category'];
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    brandController.dispose();
    priceController.dispose();
    stockController.dispose();
    imageUrlController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final productData = {
        'name': nameController.text.trim(),
        'brand': brandController.text.trim(),
        'category': selectedCategory.value,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'stock': int.tryParse(stockController.text) ?? 0,
        'image_url': imageUrlController.text.trim(),
        'description': descriptionController.text.trim(),
      };

      if (isEditMode.value && productId != null) {
        // Update
        await supabase.from('products').update(productData).eq('id', productId as Object);
        Get.snackbar('Berhasil', 'Produk berhasil diperbarui', backgroundColor: Colors.green, colorText: Colors.white);
        try {
          Get.find<NotificationController>().addNotification('Produk Diperbarui', 'Produk ${productData['name']} berhasil diperbarui.');
        } catch(e) {}
      } else {
        // Create
        productData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        productData['features'] = [];
        productData['rating'] = 0.0;
        productData['reviews'] = 0;
        productData['is_popular'] = false;
        
        await supabase.from('products').insert(productData);
        Get.snackbar('Berhasil', 'Produk berhasil ditambahkan', backgroundColor: Colors.green, colorText: Colors.white);
        try {
          Get.find<NotificationController>().addNotification('Produk Baru', 'Produk ${productData['name']} berhasil ditambahkan ke toko.');
        } catch(e) {}
      }
      
      // Refresh list in dashboard
      if (Get.isRegistered<AdminDashboardController>()) {
        Get.find<AdminDashboardController>().fetchProducts();
      }
      
      // Beri sedikit jeda agar animasi snackbar terlihat sebelum ditutup
      await Future.delayed(const Duration(milliseconds: 300));
      Get.back(); // Go back to dashboard
    } catch (e) {
      print('Error saving product: $e');
      Get.snackbar('Error', 'Gagal menyimpan produk: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
