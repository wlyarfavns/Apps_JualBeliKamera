import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prolens_digital/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:prolens_digital/app/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:url_launcher/url_launcher.dart';


class CheckoutView extends StatelessWidget {
  const CheckoutView({Key? key}) : super(key: key);

  String _formatPrice(double price) {
    return 'Rp ' + price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final CheckoutController controller = Get.put(CheckoutController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Checkout & Lokasi',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Informasi Pengiriman
            Text(
              'Informasi Pengiriman',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2C2C2E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel('NAMA PENERIMA'),
                  _buildFormTextField(
                    controller: controller.nameController,
                    hintText: 'Nama lengkap penerima',
                  ),
                  const SizedBox(height: 16),
                  _buildFormLabel('NOMOR TELEPON'),
                  _buildFormTextField(
                    controller: controller.phoneController,
                    hintText: 'Contoh: 0812xxxxxxxx',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('PROVINSI'),
                            _buildFormTextField(
                              controller: controller.provinceController,
                              hintText: 'DKI Jakarta',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('KECAMATAN'),
                            _buildFormTextField(
                              controller: controller.districtController,
                              hintText: 'Kebayoran Baru',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('KODE POS'),
                            _buildFormTextField(
                              controller: controller.postalCodeController,
                              hintText: '12110',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormLabel('NAMA JALAN'),
                            _buildFormTextField(
                              controller: controller.streetController,
                              hintText: 'Jl. Kamboja No. 42',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFormLabel('ALAMAT LENGKAP & CATATAN'),
                  _buildFormTextField(
                    controller: controller.addressController,
                    hintText: 'Blok, RT/RW, No. Rumah, patokan, dll.',
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: Titik Pengiriman (GPS)
            Text(
              'Titik Pengiriman (GPS)',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2C2C2E)),
              ),
              child: Column(
                children: [
                  // Mock Map View / Coordinate display
                  Obx(() {
                    final isFetched = controller.isLocationFetched.value;
                    final lat = controller.latitude.value;
                    final lng = controller.longitude.value;
                    final mapUrl = "https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lng&zoom=15&size=600x200&maptype=mapnik&markers=$lat,$lng,red-pushpin";

                    return InkWell(
                      onTap: isFetched ? () async {
                        final Uri gmapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
                        if (await canLaunchUrl(gmapsUrl)) {
                          await launchUrl(gmapsUrl, mode: LaunchMode.externalApplication);
                        }
                      } : null,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isFetched ? const Color(0xFFFF3B30).withOpacity(0.4) : const Color(0xFF2C2C2E),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isFetched)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.network(
                                    mapUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Icon(Icons.map, color: Colors.grey));
                                    },
                                  ),
                                ),
                              )
                            else
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.15,
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 6,
                                      mainAxisSpacing: 1,
                                      crossAxisSpacing: 1,
                                    ),
                                    itemCount: 24,
                                    itemBuilder: (context, index) => Container(
                                      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 0.5)),
                                    ),
                                  ),
                                ),
                              ),
                            
                            if (!isFetched) ...[
                              Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white10,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white10,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.my_location,
                                color: Color(0xFF8E8E93),
                                size: 28,
                              ),
                            ],

                            Positioned(
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isFetched ? "Buka di Google Maps" : controller.locationText.value,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isFetched ? const Color(0xFF4CD964) : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 14),

                  // GPS trigger button
                  Obx(() {
                    final isFetching = controller.isFetchingLocation.value;
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isFetching ? null : () => controller.fetchGPSCoordinates(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2E),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF3A3A3C)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isFetching) ...[
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ] else ...[
                              const Icon(Icons.gps_fixed, color: Color(0xFFFF3B30), size: 18),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              isFetching ? 'Mengambil Koordinat...' : 'Ambil Lokasi Saya (GPS)',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: Ringkasan Belanja
            Text(
              'Ringkasan Belanja',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2C2C2E)),
              ),
              child: Column(
                children: [
                  // List selected products
                  ...controller.cartController.cartItems
                      .where((item) => item.isSelected.value)
                      .map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF3A3A3C)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    item.product.imageUrl,
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(width: 45, height: 45, color: Colors.grey, child: const Icon(Icons.broken_image, size: 20)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.product.category} • ${item.quantity.value} pcs',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFFAEAEB2),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatPrice(item.product.price * item.quantity.value),
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  const Divider(color: Color(0xFF2C2C2E), height: 24),

                  // Pricing rows
                  _buildCostRow('Total Harga (Barang)', _formatPrice(controller.subtotal)),
                  const SizedBox(height: 8),
                  _buildCostRow('Ongkos Kirim (Kamera Pro)', _formatPrice(controller.shippingFee)),
                  const SizedBox(height: 8),
                  _buildCostRow('Asuransi Pengiriman', _formatPrice(controller.insuranceFee)),
                  const Divider(color: Color(0xFF2C2C2E), height: 24),

                  // Total Payment
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _formatPrice(controller.totalPayment),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF3B30),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: Metode Pembayaran (Transfer Bukti Manual)
            Text(
              'Unggah Bukti Pembayaran',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2C2C2E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel('UNGGAH BUKTI TRANSFER (GAMBAR)'),
                  const SizedBox(height: 6),
                  Obx(() {
                    final proofUrl = controller.paymentProofUrl.value;
                    final isUploaded = proofUrl.isNotEmpty;
                    return InkWell(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1200,
                          maxHeight: 1200,
                        );
                        if (image != null) {
                          controller.paymentProofUrl.value = image.path;
                          Get.snackbar(
                            'Upload Sukses',
                            'Bukti transfer berhasil dipilih!',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: const Color(0xFF4CD964),
                            colorText: Colors.white,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isUploaded ? const Color(0xFF4CD964) : const Color(0xFF3A3A3C),
                            width: 1.5,
                          ),
                        ),
                        child: isUploaded
                            ? Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(9),
                                      child: _buildPaymentProofImage(proofUrl),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4CD964),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      color: Colors.black.withOpacity(0.6),
                                      child: Text(
                                        'Ganti Bukti Transfer',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Color(0xFFFF3B30),
                                    size: 38,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pilih / Unggah Gambar Bukti Transfer',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFFAEAEB2),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Dukung format JPG, PNG, JPEG',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => controller.confirmOrder(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Konfirmasi Pesanan',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentProofImage(String url) {
    if (kIsWeb) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else {
      return Image.file(
        io.File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: const Color(0xFFAEAEB2),
        ),
      ),
    );
  }

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3A3C)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: const Color(0xFF8E8E93), fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFFAEAEB2),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
