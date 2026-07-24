import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prolens_digital/app/modules/cart/controllers/cart_controller.dart';
import 'package:prolens_digital/app/modules/home/controllers/notification_controller.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  
  // User info
  var name = 'Tamu (Guest)'.obs;
  var email = ''.obs;
  var profilePhoto = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80'.obs;
  var role = 'Pengunjung'.obs;
  var statsOrders = 0.obs;
  var statsWishlist = 0.obs;
  var statsReviews = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to Auth State Changes
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        isLoggedIn.value = true;
        email.value = session.user.email ?? '';
        name.value = session.user.userMetadata?['full_name'] ?? 'Pengguna Pro-Lens';
        role.value = 'Pro Photographer';
        
        // Tarik riwayat pesanan
        try {
          final cartController = Get.find<CartController>();
          cartController.fetchMyOrders();
        } catch (e) {
          print('CartController not found yet');
        }
      } else {
        isLoggedIn.value = false;
        name.value = 'Tamu (Guest)';
        email.value = '';
        role.value = 'Pengunjung';
      }
    });
  }

  Future<bool> register(String fullName, String emailAddress, String password) async {
    if (fullName.isEmpty || emailAddress.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Semua kolom pendaftaran harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF3B30),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    }
    
    isLoading.value = true;
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: emailAddress,
        password: password,
        data: {'full_name': fullName},
      );
      
      if (res.user != null) {
        await _ensureProfileExists(res.user!, fullName: fullName);
      }

      // Wait a moment for onAuthStateChange to trigger
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        Get.find<NotificationController>().addNotification('Registrasi Berhasil', 'Selamat datang di Pro-Lens Digital, $fullName!');
      } catch(e) {}

      Get.offAllNamed('/home');
      Get.snackbar(
        'Registrasi Berhasil',
        'Akun profesional Anda berhasil dibuat!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CD964),
        colorText: const Color(0xFFFFFFFF),
      );
      return true;
    } on AuthException catch (e) {
      Get.snackbar(
        'Pendaftaran Gagal',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF3B30),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF3B30),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String emailAddress, String password) async {
    if (emailAddress.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Email dan kata sandi harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF3B30),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    }

    isLoading.value = true;
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: emailAddress,
        password: password,
      );
      
      if (res.user != null) {
        await _ensureProfileExists(res.user!);
      }
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        Get.find<NotificationController>().addNotification('Login Berhasil', 'Selamat datang kembali, jangan lewatkan promo alat fotografi hari ini!');
      } catch(e) {}

      Get.offAllNamed('/home');
      Get.snackbar(
        'Berhasil Masuk',
        'Selamat datang kembali di Pro-Lens Digital!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CD964),
        colorText: const Color(0xFFFFFFFF),
      );
      return true;
    } on AuthException catch (e) {
      Get.snackbar(
        'Login Gagal',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF3B30),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF3B30),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void loginAsGuest() {
    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      isLoading.value = false;
      name.value = 'Tamu (Guest)';
      email.value = 'guest@prolens.com';
      role.value = 'Pengunjung';
      isLoggedIn.value = true;
      Get.offAllNamed('/home');
      Get.snackbar(
        'Berhasil Masuk',
        'Anda masuk sebagai Tamu.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CD964),
        colorText: const Color(0xFFFFFFFF),
      );
    });
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed('/login');
    Get.snackbar(
      'Keluar',
      'Anda telah keluar dari akun.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E1E1E),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      // 1. Inisialisasi Google Sign-In dengan Web Client ID
      const webClientId = '796196215934-mhofdd1v93muflonn5dobt2onpjspfp8.apps.googleusercontent.com';
      
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: webClientId,
      );
      
      // 2. Munculkan dialog Google Accounts bawaan Android
      final googleUser = await googleSignIn.authenticate();
      if (googleUser == null) {
        isLoading.value = false;
        return; // User membatalkan login
      }
      
      // 3. Dapatkan Token Autentikasi (Hanya idToken di v7)
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw 'Token Google tidak ditemukan. Pastikan Web Client ID benar.';
      }
      
      // 4. Kirim Token ke Supabase untuk mengesahkan akun di database
      final AuthResponse res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      
      // 5. Sukses! Ambil data profil dari Supabase
      final user = res.user;
      if (user != null) {
        await _ensureProfileExists(user, fullName: googleUser.displayName, avatarUrl: googleUser.photoUrl);

        name.value = user.userMetadata?['full_name'] ?? googleUser.displayName ?? 'Pengguna Google';
        email.value = user.email ?? googleUser.email;
        if (user.userMetadata?['avatar_url'] != null) {
           profilePhoto.value = user.userMetadata?['avatar_url'];
        } else if (googleUser.photoUrl != null) {
           profilePhoto.value = googleUser.photoUrl!;
        }
        
        isLoggedIn.value = true;
        
        try {
          Get.find<NotificationController>().addNotification('Google Login Berhasil', 'Selamat datang ${name.value} di Pro-Lens Digital!');
        } catch(e) {}

        Get.offAllNamed('/home');
        
        Get.snackbar(
          'Login Berhasil',
          'Selamat datang, ${name.value}!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CD964),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Login Gagal',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF3B30),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- Helper untuk Membatasi Akses Tamu ---
  bool checkGuestAccess() {
    if (role.value == 'Pengunjung' || name.value.contains('Tamu')) {
      Get.defaultDialog(
        title: 'Akses Terbatas',
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        middleText: 'Fitur ini hanya tersedia untuk anggota terdaftar.\nSilakan masuk atau daftar akun terlebih dahulu.',
        textConfirm: 'Masuk Sekarang',
        textCancel: 'Nanti',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFFF3B30),
        cancelTextColor: Colors.grey[700],
        onConfirm: () {
          Get.back(); // tutup dialog
          logout(); // arahkan ke halaman login
        },
      );
      return false; // Ditolak
    }
    return true; // Diizinkan
  }
  
  Future<void> _ensureProfileExists(User user, {String? fullName, String? avatarUrl}) async {
    try {
      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName ?? user.userMetadata?['full_name'] ?? 'Pengguna',
        'avatar_url': avatarUrl ?? user.userMetadata?['avatar_url'],
        'email': user.email ?? '-',
        'phone': user.phone ?? '-',
      });
    } catch (e) {
      print('Warning: Gagal memastikan profil di database: $e');
    }
  }
}

