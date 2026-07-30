import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prolens_digital/app/modules/auth/controllers/auth_controller.dart';
import 'package:prolens_digital/app/modules/cart/controllers/cart_controller.dart';
import 'package:prolens_digital/app/routes/app_routes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

class ProfilTab extends StatelessWidget {
  const ProfilTab({Key? key}) : super(key: key);

  String _formatPrice(double price) {
    return 'Rp ' + price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0E),
        elevation: 0,
        title: Text(
          'Profil Pengguna',
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
            'Profil Anda telah disegarkan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF1C1C1E),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile info
            Center(
              child: Obx(() {
                return Column(
                  children: [
                    // Avatar image circle
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF3B30), width: 2),
                        image: DecorationImage(
                          image: NetworkImage(authController.profilePhoto.value),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authController.name.value,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        authController.role.value,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 24),

            // Stats row (Highly dynamic now!)
            Obx(() {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2C2C2E)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCol('${cartController.orderHistory.length}', 'Pesanan'),
                    _buildVerticalDivider(),
                    _buildStatCol('${cartController.wishlistItems.length}', 'Wishlist'),
                    _buildVerticalDivider(),
                    _buildStatCol('${authController.statsReviews.value}', 'Ulasan'),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Menu List (All fully functional!)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildMenuRow(Icons.receipt_long_outlined, 'Pesanan Saya', () {
                    if (authController.checkGuestAccess()) {
                      _showPesananSayaSheet(context, cartController);
                    }
                  }),
                  _buildMenuRow(Icons.favorite_border, 'Daftar Keinginan', () {
                    if (authController.checkGuestAccess()) {
                      _showDaftarKeinginanSheet(context, cartController);
                    }
                  }),
                  _buildMenuRow(Icons.payment, 'Metode Pembayaran', () {
                    if (authController.checkGuestAccess()) {
                      _showMetodePembayaranSheet(context);
                    }
                  }),
                  _buildMenuRow(Icons.settings_outlined, 'Pengaturan', () {
                    if (authController.checkGuestAccess()) {
                      _showPengaturanSheet(context);
                    }
                  }),
                  _buildMenuRow(Icons.help_outline, 'Pusat Bantuan', () {
                    _showPusatBantuanSheet(context);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // Keluar button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Get.defaultDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      title: 'Keluar',
                      titleStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      middleText: 'Apakah Anda yakin ingin keluar dari akun?',
                      middleTextStyle: GoogleFonts.inter(color: Colors.white70),
                      textConfirm: 'Ya, Keluar',
                      confirmTextColor: Colors.white,
                      textCancel: 'Batal',
                      cancelTextColor: const Color(0xFFFF3B30),
                      buttonColor: const Color(0xFFFF3B30),
                      onConfirm: () {
                        Get.back();
                        authController.logout();
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF3B30),
                    side: const BorderSide(color: Color(0xFF2C2C2E), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF1C1C1E),
                  ),
                  child: Text(
                    'KELUAR',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStatCol(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFFAEAEB2),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0xFF2C2C2E),
    );
  }

  Widget _buildMenuRow(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Material(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF8E8E93), size: 18),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
      ),
    );
  }

  // --- FULLY FUNCTIONAL BOTTOM SHEETS ---

  // 1. Pesanan Saya (My Orders List with Coordinates!)
  void _showPesananSayaSheet(BuildContext context, CartController cartController) {
    Get.bottomSheet(
      Container(
        height: context.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Riwayat Pesanan Saya',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final orders = cartController.orderHistory;
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long, color: Colors.grey, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada riwayat pemesanan.',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final date = order['date'] as DateTime;
                    final items = order['items'] as List;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3A3A3C)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order['id'].toString().substring(0, 12),
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF3B30),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                style: GoogleFonts.inter(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Color(0xFF3A3A3C), height: 20),
                          
                          // Item summaries
                          ...items.map((it) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${it['name']} x${it['quantity']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                                  ),
                                ),
                                Text(
                                  _formatPrice(it['price'] * it['quantity']),
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          )).toList(),
                          const Divider(color: Color(0xFF3A3A3C), height: 20),

                          // Customer details + Coordinates
                          _buildDetailRow('Penerima', order['name']?.toString() ?? ''),
                          if (order['province'] != null) _buildDetailRow('Provinsi', order['province'].toString()),
                          if (order['district'] != null) _buildDetailRow('Kecamatan', order['district'].toString()),
                          if (order['postalCode'] != null) _buildDetailRow('Kode Pos', order['postalCode'].toString()),
                          if (order['street'] != null) _buildDetailRow('Nama Jalan', order['street'].toString()),
                          _buildDetailRow('Alamat Lengkap', order['address']?.toString() ?? ''),
                          _buildDetailRow('Koordinat GPS', '${order['lat'] != null ? (order['lat'] as double).toStringAsFixed(6) : "0.0"}, ${order['lng'] != null ? (order['lng'] as double).toStringAsFixed(6) : "0.0"}'),
                          if (order['paymentProofUrl'] != null && order['paymentProofUrl'].toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Bukti Pembayaran:',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                             ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: kIsWeb
                                  ? Image.network(
                                      order['paymentProofUrl'].toString(),
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, color: Colors.grey),
                                    )
                                  : Image.file(
                                      io.File(order['paymentProofUrl'].toString()),
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                            ),
                          ],
                          
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Pembayaran',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70),
                              ),
                              Text(
                                _formatPrice(order['total'] as double),
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFFFF3B30)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Status Pesanan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70)),
                              _buildStatusBadge(order['status']?.toString() ?? 'pending'),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'SUCCES':
        color = const Color(0xFF4CD964);
        label = 'Di-ACC / Sukses';
        break;
      case 'processing':
        color = Colors.blue;
        label = 'Sedang Diproses';
        break;
      case 'shipped':
        color = Colors.orange;
        label = 'Sedang Dikirim';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Selesai';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Dibatalkan';
        break;
      case 'pending':
      default:
        color = Colors.grey;
        label = 'Menunggu ACC';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
          children: [
            TextSpan(text: value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // 2. Daftar Keinginan (Wishlist Sheet with click detail / add to cart)
  void _showDaftarKeinginanSheet(BuildContext context, CartController cartController) {
    Get.bottomSheet(
      Container(
        height: context.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Daftar Keinginan (Wishlist)',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final wishlist = cartController.wishlistItems;
                if (wishlist.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_border, color: Colors.grey, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada produk favorit.',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: wishlist.length,
                  itemBuilder: (context, index) {
                    final product = wishlist[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3A3A3C)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.back();
                              Get.toNamed(Routes.DETAIL, arguments: product);
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(product.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Get.back();
                                Get.toNamed(Routes.DETAIL, arguments: product);
                              },
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
                                  Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatPrice(product.price),
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                                onPressed: () {
                                  cartController.addProduct(product);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite, color: Color(0xFFFF3B30), size: 20),
                                onPressed: () {
                                  cartController.toggleWishlist(product);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // 3. Metode Pembayaran Sheet
  void _showMetodePembayaranSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 380,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('Metode Pembayaran', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            _buildCardTile('Master Card', '**** **** **** 8842', Icons.credit_card, true),
            const SizedBox(height: 10),
            _buildCardTile('GoPay Wallet', 'Terhubung (0812-3456-xxxx)', Icons.account_balance_wallet, false),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar('Tambah Metode', 'Fitur integrasi sistem gateway pembayaran sandbox.',
                      backgroundColor: const Color(0xFF1C1C1E), colorText: Colors.white);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Tambah Kartu Baru', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTile(String name, String details, IconData icon, bool isDefault) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3C)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF3B30), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                Text(details, style: GoogleFonts.inter(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFFF3B30).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
              child: Text('UTAMA', style: GoogleFonts.inter(color: const Color(0xFFFF3B30), fontSize: 9, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // 4. Pengaturan Sheet
  void _showPengaturanSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 340,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('Pengaturan Aplikasi', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            _buildSettingSwitch('Mode Malam (Premium Dark)', true, (v) {}),
            _buildSettingSwitch('Push Notifications', true, (v) {}),
            _buildSettingSwitch('Layanan GPS Otomatis', true, (v) {}),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(String title, bool val, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3C)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          Switch(
            value: val,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF3B30),
          ),
        ],
      ),
    );
  }

  // 5. Pusat Bantuan Sheet
  void _showPusatBantuanSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: context.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('Pusat Bantuan & FAQ', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildFAQTile('Bagaimana cara memesan kamera?', 'Pilih produk dari beranda, klik "Tambah ke Keranjang", masuk ke menu keranjang, lalu klik "Checkout" untuk memasukkan data alamat dan GPS.'),
                  _buildFAQTile('Mengapa koordinat GPS diperlukan?', 'Berdasarkan regulasiBNSP/perusahaan, koordinat GPS lat/lng dibutuhkan agar kurir pengiriman dapat melacak lokasi rumah Anda secara presisi.'),
                  _buildFAQTile('Bagaimana melacak pesanan saya?', 'Buka tab "Profil", lalu klik menu "Pesanan Saya". Semua pesanan beserta info GPS, harga, dan waktu akan tercatat di sana.'),
                  _buildFAQTile('Apakah data transaksi aman?', 'Ya, semua data pengiriman dan koordinat GPS disimpan terenkripsi di server admin Pro-Lens.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3C)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        iconColor: const Color(0xFFFF3B30),
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Text(
            answer,
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}
