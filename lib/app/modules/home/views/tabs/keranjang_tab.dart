import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prolens_digital/app/routes/app_pages.dart';
import 'package:prolens_digital/app/modules/cart/controllers/cart_controller.dart';
import 'package:prolens_digital/app/modules/auth/controllers/auth_controller.dart';
import 'package:prolens_digital/app/modules/home/controllers/home_controller.dart';
import 'package:prolens_digital/app/modules/cart/controllers/cart_controller.dart';
import 'package:prolens_digital/app/routes/app_routes.dart';


class KeranjangTab extends StatelessWidget {
  const KeranjangTab({Key? key}) : super(key: key);

  String _formatPrice(double price) {
    return 'Rp ' + price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final AuthController authController = Get.find<AuthController>();
    final HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0E),
        elevation: 0,
        title: Text(
          'Keranjang Belanja',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFFF3B30)),
            onPressed: () {
              if (cartController.cartItems.isEmpty) return;
              Get.defaultDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: 'Kosongkan Keranjang',
                titleStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                middleText: 'Apakah Anda yakin ingin menghapus semua barang dari keranjang?',
                middleTextStyle: GoogleFonts.inter(color: Colors.white70),
                textConfirm: 'Ya, Hapus',
                confirmTextColor: Colors.white,
                textCancel: 'Batal',
                cancelTextColor: const Color(0xFFFF3B30),
                buttonColor: const Color(0xFFFF3B30),
                onConfirm: () {
                  cartController.clearCart();
                  Get.back();
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final items = cartController.cartItems;
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFF3A3A3C),
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'Keranjang Belanja Kosong',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jelajahi galeri pro kami dan pilih kamera impian Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFAEAEB2),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    homeController.changeTab(0); // Go to Home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Mulai Belanja',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Select All Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              color: const Color(0xFF161618),
              child: Row(
                children: [
                  Checkbox(
                    value: cartController.isAllSelected,
                    onChanged: (val) {
                      cartController.toggleAll(val ?? false);
                    },
                    activeColor: const Color(0xFFFF3B30),
                    checkColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF3A3A3C)),
                  ),
                  Text(
                    'Pilih Semua (${cartController.cartItems.length} barang)',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2C2C2E), height: 1),

            // Cart Items List
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFFF3B30),
                backgroundColor: const Color(0xFF1C1C1E),
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  Get.snackbar(
                    'Diperbarui',
                    'Keranjang Anda telah disegarkan',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: const Color(0xFF1C1C1E),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildCartCard(item, cartController);
                },
              ),
              ),
            ),

            // Bottom Summary & Checkout Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1E),
                border: Border(
                  top: BorderSide(color: Color(0xFF2C2C2E)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total (${cartController.selectedItemsCount} Item)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFFAEAEB2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPrice(cartController.totalPrice),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 150,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: cartController.selectedItemsCount == 0
                            ? null
                            : () {
                                if (authController.checkGuestAccess()) {
                                  Get.toNamed(Routes.CHECKOUT);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          disabledBackgroundColor: const Color(0xFF2C2C2E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Checkout',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCartCard(CartItem item, CartController cartController) {
    return Obx(() {
      final product = item.product;
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2C2C2E)),
        ),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: item.isSelected.value,
              onChanged: (val) {
                cartController.toggleSelection(item);
              },
              activeColor: const Color(0xFFFF3B30),
              checkColor: Colors.white,
              side: const BorderSide(color: Color(0xFF3A3A3C)),
            ),
            
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF3B30),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(product.price),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity Adjuster and Delete Icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFF8E8E93), size: 18),
                  onPressed: () {
                    cartController.removeProduct(item);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => cartController.decreaseQuantity(item),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Icon(Icons.remove, color: Colors.white, size: 14),
                        ),
                      ),
                      Text(
                        '${item.quantity.value}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => cartController.increaseQuantity(item),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Icon(Icons.add, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
