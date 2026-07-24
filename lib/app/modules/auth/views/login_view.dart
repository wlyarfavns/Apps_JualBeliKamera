import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController authController = Get.put(AuthController());
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF3B30).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFFFF3B30),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PRO-LENS DIGITAL',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                'Masuk Akun',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Masuk untuk mengakses portal peralatan fotografi profesional Anda.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFFAEAEB2),
                ),
              ),
              
              const SizedBox(height: 16),
 
              // Email Field
              _buildLabel('EMAIL / USERNAME'),
              _buildTextField(
                controller: emailController,
                hintText: 'name@domain.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
 
              // Password Field
              _buildLabel('KATA SANDI'),
              _buildTextField(
                controller: passwordController,
                hintText: 'Masukkan kata sandi Anda',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFFAEAEB2),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 2),
              
              // Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Get.snackbar(
                      'Lupa Kata Sandi',
                      'Tautan pemulihan kata sandi telah dikirim ke email Anda!',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFF1E1E1E),
                      colorText: Colors.white,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Lupa Kata Sandi?',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFAEAEB2),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              
              // Submit Button
              Obx(() {
                final isLoading = authController.isLoading.value;
                return SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            authController.login(
                              emailController.text,
                              passwordController.text,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Masuk →',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              }),
              
              const SizedBox(height: 16),
              
              // "Atau" Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFF2C2C2E), thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Atau',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFF2C2C2E), thickness: 1)),
                ],
              ),
              
              const SizedBox(height: 12),

              // Social logins
              _buildSocialButton(
                icon: Icons.g_mobiledata_rounded,
                text: 'Masuk dengan Google',
                onPressed: () {
                  authController.signInWithGoogle();
                },
              ),
              const SizedBox(height: 8),
              _buildSocialButton(
                icon: Icons.person_outline_rounded,
                text: 'Masuk dengan Tamu',
                onPressed: () {
                  authController.loginAsGuest();
                },
              ),
              
              const SizedBox(height: 12),
              
              // Footer link
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(Routes.REGISTER),
                  child: RichText(
                    text: TextSpan(
                      text: 'Belum memiliki akun? ',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFFAEAEB2),
                      ),
                      children: [
                        TextSpan(
                          text: 'Daftar sekarang',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF3B30),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: const Color(0xFFAEAEB2),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: const Color(0xFF8E8E93), fontSize: 15),
          prefixIcon: Icon(icon, color: const Color(0xFF8E8E93), size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF2C2C2E), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFF1C1C1E),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

