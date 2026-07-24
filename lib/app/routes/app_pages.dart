import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/detail/views/detail_view.dart';
import '../modules/checkout/views/checkout_view.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/cart/controllers/cart_controller.dart';
import '../modules/checkout/controllers/checkout_controller.dart';
import '../modules/splash/views/splash_view.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<CartController>(() => CartController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.DETAIL,
      page: () => const DetailView(),
      binding: BindingsBuilder(() {
        // DetailView reads parameter to show details
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.CHECKOUT,
      page: () => const CheckoutView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CheckoutController>(() => CheckoutController());
      }),
      transition: Transition.rightToLeft,
    ),
  ];
}
