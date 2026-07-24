import 'package:get/get.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });
}

class NotificationController extends GetxController {
  // Daftar reaktif notifikasi
  var notifications = <NotificationModel>[].obs;

  // Menambah notifikasi baru
  void addNotification(String title, String message) {
    final notif = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      date: DateTime.now(),
    );
    // Masukkan di paling atas
    notifications.insert(0, notif);
  }

  // Hitung jumlah yang belum dibaca
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  // Menandai semua sudah dibaca
  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }

  // Membersihkan riwayat notifikasi (Opsional)
  void clearAll() {
    notifications.clear();
  }
}
