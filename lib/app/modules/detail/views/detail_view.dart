import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prolens_digital/app/data/models/product_model.dart';
import 'package:prolens_digital/app/modules/cart/controllers/cart_controller.dart';
import 'package:prolens_digital/app/modules/auth/controllers/auth_controller.dart';
import 'package:prolens_digital/app/routes/app_routes.dart';


class DetailView extends StatefulWidget {
  const DetailView({Key? key}) : super(key: key);

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  late ProductModel product;
  final CartController cartController = Get.find<CartController>();
  
  // Track selected image index for slider mockup
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Get product passed as argument
    product = Get.arguments as ProductModel;
  }

  String _formatPrice(double price) {
    return 'Rp ' + price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    // Generate simulated image gallery urls using different sizes or filters for variety
    final List<String> images = [
      product.imageUrl,
      product.imageUrl.replaceAll('w=600', 'w=601'),
      product.imageUrl.replaceAll('w=600', 'w=602'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              Get.snackbar('Bagikan', 'Tautan produk berhasil disalin!',
                  backgroundColor: const Color(0xFF1C1C1E), colorText: Colors.white);
            },
          ),
          Obx(() {
            final isFav = cartController.isProductInWishlist(product);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? const Color(0xFFFF3B30) : Colors.white,
              ),
              onPressed: () {
                if (authController.checkGuestAccess()) {
                  cartController.toggleWishlist(product);
                }
              },
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Large Image View
            Container(
              height: 380,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(images[_selectedImageIndex]),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Color(0xFF0D0D0E),
                    ],
                  ),
                ),
              ),
            ),

            // Image Thumbnails Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  final isSelected = _selectedImageIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF3B30) : const Color(0xFF2C2C2E),
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Product Details Block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.brand,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF3B30),
                          letterSpacing: 2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Stok Tersedia',
                          style: GoogleFonts.inter(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatPrice(product.price),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF3B30),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    product.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.6,
                      color: const Color(0xFFAEAEB2),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Fitur Utama
                  Text(
                    'Fitur Utama',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.features.length,
                      itemBuilder: (context, index) {
                        final feature = product.features[index];
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2C2C2E)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bolt, color: Color(0xFFFF3B30), size: 20),
                              const SizedBox(height: 8),
                              Text(
                                feature,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Spesifikasi Teknis
                  Text(
                    'Spesifikasi Teknis',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2C2C2E)),
                    ),
                    child: Column(
                      children: product.specs.entries.map((entry) {
                        final isLast = product.specs.entries.last.key == entry.key;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      entry.key,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFAEAEB2),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              const Divider(color: Color(0xFF2C2C2E), height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Ulasan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ulasan (${product.rating}/5)',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.snackbar('Ulasan', 'Membuka galeri ulasan lengkap...',
                              backgroundColor: const Color(0xFF1C1C1E), colorText: Colors.white);
                        },
                        child: Text(
                          'Lihat Semua',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFFFF3B30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2C2C2E)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  color: index < product.rating.floor() ? Colors.amber : Colors.grey,
                                  size: 16,
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              product.reviewUser,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${product.reviewText}"',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFFAEAEB2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
            children: [
              // Add to Cart Button Icon
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A3C)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                  onPressed: () {
                    if (authController.checkGuestAccess()) {
                      cartController.addProduct(product);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Buy Now Button
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!authController.checkGuestAccess()) return;
                      // Add product to cart, check it, and navigate to checkout
                      cartController.addProduct(product);
                      // Make sure this item is selected in cart
                      final cartItem = cartController.cartItems.firstWhereOrNull((item) => item.product.id == product.id);
                      if (cartItem != null) {
                        cartItem.isSelected.value = true;
                      }
                      Get.toNamed(Routes.CHECKOUT);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Beli Sekarang',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
