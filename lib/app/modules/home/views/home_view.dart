import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prolens_digital/app/modules/home/controllers/home_controller.dart';
import 'package:prolens_digital/app/modules/cart/controllers/cart_controller.dart';
import 'tabs/beranda_tab.dart';
import 'tabs/cari_tab.dart';
import 'tabs/keranjang_tab.dart';
import 'tabs/profil_tab.dart';


class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final CartController cartController = Get.find<CartController>();

    final List<Widget> tabs = [
      const BerandaTab(),
      const CariTab(),
      const KeranjangTab(),
      const ProfilTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      body: Obx(() => IndexedStack(
            index: controller.selectedTab.value,
            children: tabs,
          )),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: controller.selectedTab.value,
          onTap: (index) {
            controller.changeTab(index);
          },
          backgroundColor: const Color(0xFF1C1C1E),
          selectedItemColor: const Color(0xFFFF3B30),
          unselectedItemColor: const Color(0xFF8E8E93),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 8,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Cari',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Obx(() {
                      final count = cartController.totalItemsCount;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B30),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              activeIcon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart),
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Obx(() {
                      final count = cartController.totalItemsCount;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B30),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              label: 'Keranjang',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        );
      }),
    );
  }
}
