import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/modules/cart/controllers/cart_controller.dart';
import 'app/modules/home/controllers/home_controller.dart';
import 'app/modules/home/controllers/notification_controller.dart';


import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Ensure visual services initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://jzcqqtybnnvvhiuuqlvq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6Y3FxdHlibm52dmhpdXVxbHZxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ3MzA2NTgsImV4cCI6MjEwMDMwNjY1OH0.pvAiY8F1CGrFZnJHFZ8U8LvTWhFxxSBlyHhBYE4w69g',
  );
  
  // Force status bar to be transparent on android/ios
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF1C1C1E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pro-Lens Digital',
      debugShowCheckedModeBanner: false,
      
      // Global Custom Premium Dark Theme
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0E),
        primaryColor: const Color(0xFFFF3B30),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF3B30),
          secondary: Color(0xFFFF3B30),
          background: Color(0xFF0D0D0E),
          surface: Color(0xFF1C1C1E),
          error: Color(0xFFFF3B30),
        ),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF0D0D0E),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFFFF3B30);
            }
            return null;
          }),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      
      initialBinding: BindingsBuilder(() {
        Get.put(NotificationController(), permanent: true);
        Get.put(AuthController(), permanent: true);
        Get.put(CartController(), permanent: true);
        Get.put(HomeController(), permanent: true);
      }),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
