import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:prolens_digital/app/modules/auth/controllers/auth_controller.dart';

class AdminDashboardController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoadingOrders = false.obs;
  var isLoadingCustomers = false.obs;

  var orders = <Map<String, dynamic>>[].obs;
  var customers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    fetchCustomers();
  }

  Future<void> fetchOrders() async {
    isLoadingOrders.value = true;
    try {
      // Ambil semua orders beserta item-itemnya
      final ordersResponse = await supabase
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);
          
      // Ambil semua profil pelanggan (untuk dicocokkan dengan user_id di orders)
      final profilesResponse = await supabase
          .from('profiles')
          .select('id, full_name, email, phone');
          
      // Buat map profile untuk akses cepat
      Map<String, dynamic> profileMap = {};
      for (var profile in profilesResponse) {
        profileMap[profile['id']] = profile;
      }
      
      // Gabungkan data
      List<Map<String, dynamic>> combinedOrders = [];
      for (var order in ordersResponse) {
        var orderData = Map<String, dynamic>.from(order);
        orderData['profiles'] = profileMap[order['user_id']];
        combinedOrders.add(orderData);
      }
          
      orders.assignAll(combinedOrders);
    } catch (e) {
      print('Error fetching orders: $e');
      Get.snackbar('Error', 'Gagal memuat data pesanan: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> fetchCustomers() async {
    isLoadingCustomers.value = true;
    try {
      final response = await supabase
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);
          
      customers.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      print('Error fetching customers: $e');
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus, String oldStatus) async {
    try {
      // Update status di Supabase
      await supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);
          
      // Logika pengurangan stok: 
      // Jika pesanan di-ACC (menjadi SUCCES/processing/shipped) dan sebelumnya masih pending
      if ((newStatus == 'SUCCES' || newStatus == 'processing' || newStatus == 'shipped') && 
          oldStatus == 'pending') {
          
        try {
          final orderItems = await supabase
              .from('order_items')
              .select('product_id, quantity')
              .eq('order_id', orderId);
              
          for (var item in orderItems) {
            await supabase.rpc('decrement_stock', params: {
              'product_id': item['product_id'],
              'qty': item['quantity'],
            });
          }
        } catch (e) {
          print('Gagal mengurangi stok: $e');
        }
      }
          
      // Update local state
      int index = orders.indexWhere((o) => o['id'] == orderId);
      if (index != -1) {
        var updatedOrder = Map<String, dynamic>.from(orders[index]);
        updatedOrder['status'] = newStatus;
        orders[index] = updatedOrder;
        orders.refresh();
      }
      
      Get.snackbar('Berhasil', 'Status pesanan diperbarui menjadi $newStatus', 
        backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print('Error updating order status: $e');
      Get.snackbar('Error', 'Gagal memperbarui status', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  
  void logout() {
    Get.find<AuthController>().logout();
  }
}
