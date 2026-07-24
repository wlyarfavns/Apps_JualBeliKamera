import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prolens_digital/app/data/models/product_model.dart';
import 'package:prolens_digital/app/modules/home/controllers/home_controller.dart';
import 'package:prolens_digital/app/modules/cart/controllers/cart_controller.dart';
import 'package:prolens_digital/app/routes/app_routes.dart';


class CariTab extends StatefulWidget {
  const CariTab({Key? key}) : super(key: key);

  @override
  State<CariTab> createState() => _CariTabState();
}

class _CariTabState extends State<CariTab> {
  final textController = TextEditingController();
  final homeController = Get.find<HomeController>();

  final List<String> popularCategories = ['Sony', 'Canon', 'Lensa Prime', 'Tripod', 'Aksesoris'];

  @override
  void initState() {
    super.initState();
    // Synchronize text field with search query in controller
    textController.text = homeController.searchQuery.value;
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    return 'Rp ' + price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _runSearch(String query) {
    textController.text = query;
    homeController.updateSearch(query);
    homeController.addRecentSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0E),
        elevation: 0,
        title: Text(
          'Cari Kamera & Lensa',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFF3B30),
        backgroundColor: const Color(0xFF1C1C1E),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          Get.snackbar(
            'Diperbarui',
            'Data pencarian telah disegarkan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF1C1C1E),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C2C2E)),
                ),
                child: TextField(
                  controller: textController,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  textInputAction: TextInputAction.search,
                  onChanged: (val) {
                    homeController.updateSearch(val);
                  },
                  onSubmitted: (val) {
                    _runSearch(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari kamera, lensa, atau aksesoris...',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF8E8E93), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF8E8E93)),
                    suffixIcon: Obx(() {
                      if (homeController.searchQuery.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF8E8E93)),
                        onPressed: () {
                          textController.clear();
                          homeController.updateSearch('');
                        },
                      );
                    }),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Kategori Populer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Kategori Populer',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: popularCategories.length,
                itemBuilder: (context, index) {
                  final cat = popularCategories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ActionChip(
                      label: Text(
                        cat,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: const Color(0xFF1C1C1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF2C2C2E)),
                      ),
                      onPressed: () {
                        String query = cat;
                        if (cat == 'Lensa Prime') query = 'lensa';
                        _runSearch(query);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Terakhir Dicari (Recent Searches)
            Obx(() {
              final recents = homeController.recentSearches;
              if (recents.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terakhir Dicari',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () => homeController.clearRecentSearches(),
                          child: Text(
                            'Hapus Semua',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFFFF3B30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: recents.length,
                    itemBuilder: (context, index) {
                      final item = recents[index];
                      return ListTile(
                        leading: const Icon(Icons.history, color: Color(0xFF8E8E93), size: 18),
                        title: Text(
                          item,
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF8E8E93), size: 16),
                          onPressed: () {
                            recents.removeAt(index);
                          },
                        ),
                        onTap: () {
                          _runSearch(item);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            // Rekomendasi / Hasil Pencarian
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(() {
                final isSearching = homeController.searchQuery.value.isNotEmpty;
                return Text(
                  isSearching ? 'Hasil Pencarian' : 'Rekomendasi untuk Anda',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            Obx(() {
              final list = homeController.filteredProducts;
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFFF3B30), size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Pencarian tidak cocok dengan produk apapun.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: const Color(0xFFAEAEB2), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final p = list[index];
                  return _buildRecommendationRow(p, cartController);
                },
              );
            }),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildRecommendationRow(ProductModel product, CartController cartController) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => Get.toNamed(Routes.DETAIL, arguments: product),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C2C2E)),
          ),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Product Details
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
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
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
              // Cart button
              IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: Color(0xFFFF3B30), size: 20),
                onPressed: () {
                  cartController.addProduct(product);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
