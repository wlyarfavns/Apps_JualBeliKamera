import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:prolens_digital/app/modules/cart/controllers/cart_controller.dart';
import 'package:prolens_digital/app/modules/home/controllers/notification_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'package:supabase_flutter/supabase_flutter.dart';



class CheckoutController extends GetxController {
  final CartController cartController = Get.find<CartController>();

  // Text Editing Controllers for Checkout Form
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final provinceController = TextEditingController();
  final districtController = TextEditingController();
  final postalCodeController = TextEditingController();
  final streetController = TextEditingController();
  final addressController = TextEditingController();

  // Payment proof state
  var paymentProofUrl = "".obs;
  var paymentMethod = "Transfer Bank".obs;

  // Location/GPS state
  var isFetchingLocation = false.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var locationText = "Lokasi belum ditentukan".obs;
  var isLocationFetched = false.obs;

  // Shipping details
  final double shippingFee = 150000;
  final double insuranceFee = 125000;

  @override
  void onInit() {
    super.onInit();
    // Default form values for testing
    nameController.text = "";
    phoneController.text = "";
    provinceController.text = "";
    districtController.text = "";
    postalCodeController.text = "";
    streetController.text = "";
    addressController.text = "";
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    provinceController.dispose();
    districtController.dispose();
    postalCodeController.dispose();
    streetController.dispose();
    addressController.dispose();
    super.onClose();
  }

  // Get current GPS coordinates
  Future<void> fetchGPSCoordinates() async {
    isFetchingLocation.value = true;
    locationText.value = "Menghubungkan ke GPS...";
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin akses lokasi ditolak. Kami tidak bisa mengisi alamat otomatis.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        throw 'Izin lokasi ditolak permanen. Silakan ubah izin lokasi di Pengaturan Aplikasi agar fitur GPS bisa digunakan.';
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw 'GPS Anda mati. Silakan aktifkan GPS terlebih dahulu lalu coba klik ambil lokasi lagi.';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 15),
        ),
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      locationText.value = "Koordinat: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
      isLocationFetched.value = true;

      await reverseGeocode(position.latitude, position.longitude);

      Get.snackbar(
        'GPS Berhasil',
        'Koordinat & alamat rumah Anda berhasil diperoleh secara real-time!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CD964),
        colorText: const Color(0xFFFFFFFF),
      );
    } catch (e) {
      print("GPS Error: $e");
      
      Get.snackbar(
        'Akses Lokasi Gagal',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF3B30),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      );
    } finally {
      isFetchingLocation.value = false;
    }
  }

  // Reverse geocoding function using Google/Native Geocoding API via package
  Future<void> reverseGeocode(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        bool isPlusCode(String s) => RegExp(r'^[A-Z0-9]{2,8}\+[A-Z0-9]{2,4}').hasMatch(s);
        
        String cleanStreet = place.thoroughfare ?? '';
        if (cleanStreet.isEmpty || isPlusCode(cleanStreet)) {
           cleanStreet = place.street ?? '';
        }
        if (cleanStreet.isEmpty || isPlusCode(cleanStreet)) {
           cleanStreet = place.name ?? '';
        }
        if (isPlusCode(cleanStreet)) {
           cleanStreet = ''; 
        }
        
        if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty && cleanStreet == place.thoroughfare) {
           cleanStreet = "$cleanStreet No. ${place.subThoroughfare}";
        }

        provinceController.text = place.administrativeArea ?? '';
        districtController.text = place.subAdministrativeArea ?? place.locality ?? '';
        postalCodeController.text = place.postalCode ?? '';
        streetController.text = cleanStreet;
        
        String fullAddress = [
          cleanStreet,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode
        ].where((e) => e != null && e!.isNotEmpty).join(', ');
        
        addressController.text = fullAddress;
      }
    } catch (e) {
      print("Error in reverse geocoding: $e");
      Get.snackbar(
        'Lokasi Tidak Ditemukan',
        'Gagal mendeteksi detail alamat secara otomatis. Silakan isi alamat Anda secara manual.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF3B30),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // Calculate checkout costs
  double get subtotal => cartController.totalPrice;
  double get totalPayment => subtotal + shippingFee + insuranceFee;

  // Confirm order transaction
  Future<void> confirmOrder() async {
    if (nameController.text.trim().isEmpty || 
        phoneController.text.trim().isEmpty || 
        provinceController.text.trim().isEmpty || 
        districtController.text.trim().isEmpty || 
        postalCodeController.text.trim().isEmpty || 
        streetController.text.trim().isEmpty || 
        addressController.text.trim().isEmpty || 
        !isLocationFetched.value || 
        paymentProofUrl.value.trim().isEmpty) {
      Get.snackbar('Kesalahan', 'Mohon lengkapi semua data formulir, lokasi, dan bukti pembayaran.', 
          backgroundColor: const Color(0xFFFF3B30), colorText: Colors.white);
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      Get.snackbar('Kesalahan', 'Anda harus login terlebih dahulu.', 
          backgroundColor: const Color(0xFFFF3B30), colorText: Colors.white);
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xFFFF3B30))), barrierDismissible: false);

    try {
      // Pastikan profil user sudah ada di database sebelum insert order
      try {
        final profileCheck = await supabase.from('profiles').select('id').eq('id', user.id).maybeSingle();
        if (profileCheck == null) {
          await supabase.from('profiles').insert({
            'id': user.id,
            'full_name': user.userMetadata?['full_name'] ?? 'Pengguna',
            'avatar_url': user.userMetadata?['avatar_url'],
            'email': user.email ?? '-',
            'phone': user.phone ?? (phoneController.text.isNotEmpty ? phoneController.text : '-'),
          });
        }
      } catch (e) {
        print('Warning: Gagal memeriksa/membuat profil saat checkout: $e');
      }

      final fullAddressStr = '${addressController.text} (Lat: ${latitude.value}, Lng: ${longitude.value})';
      
      final orderResponse = await supabase.from('orders').insert({
        'user_id': user.id,
        'total_amount': totalPayment,
        'status': 'pending',
        'shipping_address': fullAddressStr,
        'payment_method': paymentMethod.value,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      final orderId = orderResponse['id'];

      final itemsToInsert = cartController.cartItems
          .where((item) => item.isSelected.value)
          .map((item) => {
                'order_id': orderId,
                'product_id': item.product.id,
                'product_name': item.product.name,
                'quantity': item.quantity.value,
                'price': item.product.price,
              })
          .toList();

      if (itemsToInsert.isNotEmpty) {
        await supabase.from('order_items').insert(itemsToInsert);
      }

      // Memuat ulang riwayat pesanan dari database ke dalam memori aplikasi
      await cartController.fetchMyOrders();
      
      try {
        Get.find<NotificationController>().addNotification('Pesanan Berhasil', 'Pesanan Anda sebesar Rp ${totalPayment.toStringAsFixed(0)} telah sukses dibuat!');
      } catch(e) {}

      Get.back(); // close loading

      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Pesanan Berhasil', style: TextStyle(color: Colors.white)),
          content: const Text('Pesanan Anda telah dikirim ke admin.', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                cartController.cartItems.removeWhere((item) => item.isSelected.value);
                Get.back(); // close dialog
                Get.back(); // back to cart/home
              },
              child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.back(); // close loading
      print("Supabase Insert Error: $e");
      Get.snackbar('Kesalahan', 'Gagal menyimpan pesanan ke database: $e', 
          backgroundColor: const Color(0xFFFF3B30), colorText: Colors.white);
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
          children: [
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
