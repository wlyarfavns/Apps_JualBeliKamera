import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                controller.logout();
              },
            )
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF3B30),
            labelColor: Color(0xFFFF3B30),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.shopping_cart), text: 'Pesanan'),
              Tab(icon: Icon(Icons.people), text: 'Pelanggan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersTab(),
            _buildCustomersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Obx(() {
      if (controller.isLoadingOrders.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFFFF3B30)));
      }
      
      if (controller.orders.isEmpty) {
        return const Center(child: Text('Belum ada pesanan.', style: TextStyle(color: Colors.white54)));
      }

      return RefreshIndicator(
        color: const Color(0xFFFF3B30),
        onRefresh: controller.fetchOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            final profile = order['profiles'];
            final customerName = profile != null ? profile['full_name'] : 'Unknown';
            final totalAmount = order['total_amount'] ?? 0;
            final status = order['status'] ?? 'pending';
            final orderId = order['id'].toString().substring(0, 8);

            return Card(
              color: const Color(0xFF1E1E1E),
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order #$orderId', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Pelanggan: $customerName', style: const TextStyle(color: Colors.white70)),
                    
                    if (order['shipping_address'] != null) ...[
                      const SizedBox(height: 4),
                      Text('Alamat: ${order['shipping_address']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],

                    const Divider(color: Colors.white24, height: 24),
                    const Text('Detail Pesanan:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    
                    if (order['order_items'] != null)
                      ...List.generate((order['order_items'] as List).length, (i) {
                        final item = order['order_items'][i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('${item['product_name'] ?? 'Produk'} (x${item['quantity']})', style: const TextStyle(color: Colors.white70))),
                              Text('Rp ${item['price']}', style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        );
                      }),
                      
                    const Divider(color: Colors.white24, height: 24),

                    Text('Total: Rp $totalAmount', style: const TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Ubah Status: ', style: TextStyle(color: Colors.white54)),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          dropdownColor: const Color(0xFF2C2C2E),
                          value: status,
                          style: const TextStyle(color: Colors.white),
                          underline: Container(height: 1, color: Colors.white24),
                          items: const [
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'SUCCES', child: Text('Di-ACC / Sukses')),
                            DropdownMenuItem(value: 'processing', child: Text('Diproses')),
                            DropdownMenuItem(value: 'shipped', child: Text('Dikirim')),
                            DropdownMenuItem(value: 'completed', child: Text('Selesai')),
                            DropdownMenuItem(value: 'cancelled', child: Text('Dibatalkan')),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null && newValue != status) {
                              controller.updateOrderStatus(order['id'], newValue, status);
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'SUCCES':
        color = const Color(0xFF4CD964);
        label = 'Di-ACC';
        break;
      case 'processing':
        color = Colors.blue;
        label = 'Diproses';
        break;
      case 'shipped':
        color = Colors.orange;
        label = 'Dikirim';
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
        label = 'Pending';
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
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCustomersTab() {
    return Obx(() {
      if (controller.isLoadingCustomers.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFFFF3B30)));
      }
      
      if (controller.customers.isEmpty) {
        return const Center(child: Text('Belum ada pelanggan.', style: TextStyle(color: Colors.white54)));
      }

      return RefreshIndicator(
        color: const Color(0xFFFF3B30),
        onRefresh: controller.fetchCustomers,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.customers.length,
          itemBuilder: (context, index) {
            final customer = controller.customers[index];
            final name = customer['full_name'] ?? 'Unknown';
            final email = customer['email'] ?? 'No email';
            final role = customer['role'] ?? 'user';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tileColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF2C2C2E),
                  child: Text(name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(email, style: const TextStyle(color: Colors.white54)),
                trailing: Text(role.toUpperCase(), style: TextStyle(color: role == 'admin' ? const Color(0xFFFF3B30) : Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            );
          },
        ),
      );
    });
  }
}
