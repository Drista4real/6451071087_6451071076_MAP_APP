import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _db = FirebaseFirestore.instance;

  /// Lấy danh sách thông báo của người dùng theo thời gian thực
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Cập nhật trạng thái đã đọc cho thông báo
  Future<void> markAsRead(String docId) async {
    await _db.collection('notifications').doc(docId).update({
      "isRead": true,
    });
  }
}