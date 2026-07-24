import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prolens_digital/app/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prolens_digital/app/modules/home/controllers/notification_controller.dart';

class CartItem {
  final ProductModel product;
  var quantity = 1.obs;
  var isSelected = true.obs;

  CartItem({required this.product, int initialQuantity = 1, bool isSelected = true}) {
    this.quantity.value = initialQuantity;
    this.isSelected.value = isSelected;
  }
}

class CartController extends GetxController {
  // Reactive cart items list
  var cartItems = <CartItem>[].obs;

  // Add a product to the cart
  void addProduct(ProductModel product) {
    // Check if product already exists in cart
    var existingItem = cartItems.firstWhereOrNull((item) => item.product.id == product.id);

    if (existingItem != null) {
      existingItem.quantity.value++;
    } else {
      cartItems.add(CartItem(product: product));
    }

    Get.snackbar(
      'Keranjang Belanja',
      '${product.name} ditambahkan ke keranjang!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E1E1E),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      icon: const Icon(Icons.check_circle_outline, color: Color(0xFF4CD964)),
    );

    try {
      Get.find<NotificationController>().addNotification('Keranjang Belanja', '${product.name} berhasil ditambahkan ke keranjang Anda.');
    } catch(e) {}
  }

  // Decrement quantity
  void decreaseQuantity(CartItem item) {
    if (item.quantity.value > 1) {
      item.quantity.value--;
    } else {
      // If 1, ask or just remove
      removeProduct(item);
    }
  }

  // Increment quantity
  void increaseQuantity(CartItem item) {
    item.quantity.value++;
  }

  // Remove completely from cart
  void removeProduct(CartItem item) {
    cartItems.remove(item);
    Get.snackbar(
      'Keranjang Belanja',
      '${item.product.name} dihapus dari keranjang!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E1E1E),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      icon: const Icon(Icons.delete_outline, color: Color(0xFFFF3B30)),
    );
  }

  // Toggle single item selection
  void toggleSelection(CartItem item) {
    item.isSelected.value = !item.isSelected.value;
    cartItems.refresh();
  }

  // Toggle selection for all items
  void toggleAll(bool selectAll) {
    for (var item in cartItems) {
      item.isSelected.value = selectAll;
    }
    cartItems.refresh();
  }

  // Check if all items are selected
  bool get isAllSelected => cartItems.isNotEmpty && cartItems.every((item) => item.isSelected.value);

  // Calculate total price of selected items
  double get totalPrice {
    double total = 0.0;
    for (var item in cartItems) {
      if (item.isSelected.value) {
        total += item.product.price * item.quantity.value;
      }
    }
    return total;
  }

  // Calculate total items count in cart (for badge)
  int get totalItemsCount {
    int count = 0;
    for (var item in cartItems) {
      count += item.quantity.value;
    }
    return count;
  }

  // Calculate selected items count
  int get selectedItemsCount {
    int count = 0;
    for (var item in cartItems) {
      if (item.isSelected.value) {
        count += item.quantity.value;
      }
    }
    return count;
  }

  // Order history storage
  var orderHistory = <Map<String, dynamic>>[].obs;

  // Wishlist items storage
  var wishlistItems = <ProductModel>[].obs;

  void addOrder(Map<String, dynamic> order) {
    orderHistory.add(order);
  }

  void toggleWishlist(ProductModel product) {
    final exists = wishlistItems.any((item) => item.id == product.id);
    if (exists) {
      wishlistItems.removeWhere((item) => item.id == product.id);
      Get.snackbar(
        'Wishlist',
        '${product.name} dihapus dari wishlist',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1E1E1E),
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        icon: const Icon(Icons.favorite_border, color: Colors.white),
      );
    } else {
      wishlistItems.add(product);
      Get.snackbar(
        'Wishlist',
        '${product.name} ditambahkan ke wishlist',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF3B30),
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        icon: const Icon(Icons.favorite, color: Colors.white),
      );
    }
  }

  bool isProductInWishlist(ProductModel product) {
    return wishlistItems.any((item) => item.id == product.id);
  }

  void clearCart() {
    cartItems.clear();
  }

  // Menarik riwayat pesanan dari Supabase
  Future<void> fetchMyOrders() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Mengambil orders dan order_items yang terhubung
      final response = await supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> fetchedOrders = [];

      for (var orderData in response) {
        final List<dynamic> rawItems = orderData['order_items'] ?? [];
        final items = rawItems.map((item) {
          return {
            'name': item['product_name'],
            'quantity': item['quantity'],
            'price': item['price'],
          };
        }).toList();

        // Mengurai shipping_address jika perlu (saat ini disimpan utuh sebagai string dengan lat/lng di ujungnya)
        // Kita simpan as-is untuk alamat lengkap, dan lat/lng default jika tidak diparse dengan baik
        double lat = 0.0;
        double lng = 0.0;
        String address = orderData['shipping_address']?.toString() ?? '';
        
        // Coba ekstrak lat lng dari format: "alamat... (Lat: xx, Lng: xx)"
        final latLngRegex = RegExp(r'\(Lat: ([-+]?[0-9]*\.?[0-9]+), Lng: ([-+]?[0-9]*\.?[0-9]+)\)');
        final match = latLngRegex.firstMatch(address);
        if (match != null) {
          lat = double.tryParse(match.group(1) ?? '0') ?? 0.0;
          lng = double.tryParse(match.group(2) ?? '0') ?? 0.0;
        }

        fetchedOrders.add({
          'id': orderData['id'],
          'date': DateTime.parse(orderData['created_at']),
          'items': items,
          'name': user.userMetadata?['full_name'] ?? 'Pengguna',
          'address': address,
          'lat': lat,
          'lng': lng,
          'total': double.parse(orderData['total_amount'].toString()),
          'status': orderData['status'],
          'paymentProofUrl': '', // Sesuaikan jika ada bukti pembayaran
        });
      }

      orderHistory.assignAll(fetchedOrders);
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }
}
