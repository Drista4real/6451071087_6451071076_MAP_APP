import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseDataSender {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> banners = [
    {
      'id': 'banner_001', 
      'image': 'https://via.placeholder.com/600x300?text=Khuyến+Mãi+Mùa+Hè', 
      'targetScreen': '/all-products', 
      'isActive': true
    },
    {
      'id': 'banner_002', 
      'image': 'https://via.placeholder.com/600x300?text=Dụng+Cụ+Mới+Về', 
      'targetScreen': '/category?id=cat_001', 
      'isActive': true
    },
  ];

  final List<Map<String, dynamic>> categories = [
    {
      'id': 'cat_001',
      'name': 'Tạ & Barbell',
      'imageURL': 'https://via.placeholder.com/150?text=Weights',
      'isActive': true,
      'isFeatured': true,
      'priority': 1,
      'numberOfProducts': 10,
      'viewCount': 100,
      'createdBy': 'admin',
      'updatedBy': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_002',
      'name': 'Máy Tập',
      'imageURL': 'https://via.placeholder.com/150?text=Machines',
      'isActive': true,
      'isFeatured': true,
      'priority': 2,
      'numberOfProducts': 5,
      'viewCount': 85,
      'createdBy': 'admin',
      'updatedBy': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_003',
      'name': 'Xà Đơn',
      'imageURL': 'https://via.placeholder.com/150?text=Bars',
      'isActive': true,
      'isFeatured': false,
      'priority': 3,
      'numberOfProducts': 7,
      'viewCount': 40,
      'createdBy': 'admin',
      'updatedBy': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  final List<Map<String, dynamic>> brands = [
    {'id': 'brand_001', 'name': 'PowerFlex Pro', 'imageURL': 'https://via.placeholder.com/150?text=PowerFlex', 'isActive': true},
  ];

  final List<Map<String, dynamic>> products = [
    {
      'id': 'prod_001', 
      'title': 'Tạ Tay 20kg', 
      'categoryId': 'cat_001', 
      'brandId': 'brand_001', 
      'price': 450000, 
      'stock': 25, 
      'thumbnail': 'https://via.placeholder.com/300?text=Tạ+20kg', 
      'isActive': true, 
      'isFeatured': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'prod_004', 
      'title': 'Máy Chạy Bộ FitZone', 
      'categoryId': 'cat_002', 
      'brandId': 'brand_001', 
      'price': 8500000, 
      'stock': 5, 
      'thumbnail': 'https://via.placeholder.com/300?text=Máy+Chạy', 
      'isActive': true, 
      'isFeatured': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  final List<Map<String, dynamic>> coupons = [
    {'id': 'coupon_001', 'code': 'FITZONE50', 'description': 'Giảm 50k đơn đầu', 'discountValue': 50000, 'isActive': true},
  ];

  /// KIỂM TRA KẾT NỐI (BẮT BỆNH)
  Future<void> checkConnection() async {
    try {
      debugPrint('🔍 Đang ping tới Project: ${_db.app.options.projectId}');
      await _db.collection('connection_test').doc('ping').set({
        'time': FieldValue.serverTimestamp(),
        'message': 'App is trying to connect...'
      }).timeout(const Duration(seconds: 8));
      debugPrint('✅ Kết nối Firestore thành công!');
    } catch (e) {
      debugPrint('❌ Lỗi kết nối Firestore: $e');
      rethrow;
    }
  }

  Future<void> sendAllDataToFirebase() async {
    try {
      final WriteBatch batch = _db.batch();
      
      for (var item in banners) {
        batch.set(_db.collection('banners').doc(item['id']), item);
        batch.set(_db.collection('Banners').doc(item['id']), item);
      }
      for (var item in categories) {
        batch.set(_db.collection('categories').doc(item['id']), item);
        batch.set(_db.collection('Categories').doc(item['id']), item);
      }
      for (var item in brands) {
        batch.set(_db.collection('brands').doc(item['id']), item);
        batch.set(_db.collection('Brands').doc(item['id']), item);
      }
      for (var item in products) {
        batch.set(_db.collection('products').doc(item['id']), item);
        batch.set(_db.collection('Products').doc(item['id']), item);
      }
      for (var item in coupons) {
        batch.set(_db.collection('coupons').doc(item['id']), item);
      }
      await batch.commit();
      debugPrint('✅ DỮ LIỆU ĐÃ CẬP NHẬT ĐÚNG CẤU TRÚC!');
    } catch (e) {
      debugPrint('❌ LỖI GỬI DỮ LIỆU: $e');
      rethrow;
    }
  }

  Future<void> deleteAllData() async {
    final WriteBatch batch = _db.batch();
    for (var item in banners) batch.delete(_db.collection('banners').doc(item['id']));
    for (var item in categories) batch.delete(_db.collection('categories').doc(item['id']));
    await batch.commit();
  }
}
