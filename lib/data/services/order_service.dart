import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;

  Future<void> createOrder(OrderModel order) async {
    await _db.collection('orders').add(order.toJson());
  }

  // Lấy danh sách đơn hàng theo kiểu Stream (Real-time)
  Stream<List<OrderModel>> getOrdersStream(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson({...data, 'docId': doc.id});
      }).toList();
      
      // Sắp xếp đơn mới nhất lên đầu
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    final snapshot = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    final orders = snapshot.docs.map((doc) {
      final data = doc.data();
      return OrderModel.fromJson({...data, 'docId': doc.id});
    }).toList();

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  Future<bool> hasUserPurchasedProduct({
    required String userId,
    required String productId,
  }) async {
    final snapshot = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('orderStatus', isEqualTo: 'delivered')
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['products'] == null) continue;
      
      final List<dynamic> products = data['products'];
      for (var item in products) {
        if (item['productId'] == productId) {
          return true;
        }
      }
    }
    return false;
  }
}