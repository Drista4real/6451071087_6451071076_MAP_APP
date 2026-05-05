import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// LẤY SẢN PHẨM PHỔ BIẾN (Giới hạn 6 món)
  Future<List<ProductModel>> getPopularProducts() async {
    final snapshot = await _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .limit(6)
        .get();

    List<ProductModel> products = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String? brandName;

      if (data['brandId'] != null) {
        final brandDoc = await _db.collection('brands').doc(data['brandId']).get();
        brandName = brandDoc.data()?['name'];
      }

      products.add(ProductModel.fromSnapshot(doc, brandName));
    }
    return products;
  }

  /// LẤY TẤT CẢ SẢN PHẨM PHỔ BIẾN + SẮP XẾP LOCAL
  Future<List<ProductModel>> getAllPopularProducts({String sortBy = "name"}) async {
    final snapshot = await _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .get();

    List<ProductModel> products = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String? brandName;

      if (data['brandId'] != null) {
        final brandDoc = await _db.collection('brands').doc(data['brandId']).get();
        brandName = brandDoc.data()?['name'];
      }
      products.add(ProductModel.fromSnapshot(doc, brandName));
    }

    // SORT LOCAL – AN TOÀN 100% không cần Index Firebase
    if (sortBy == "low_price") {
      products.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == "high_price") {
      products.sort((a, b) => b.price.compareTo(a.price));
    } else {
      products.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    return products;
  }

  /// LẤY SẢN PHẨM THEO DANH MỤC
  Future<List<ProductModel>> getProductsByCategory({required String categoryId}) async {
    final snapshot = await _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('categoryIds', arrayContains: categoryId)
        .get();

    List<ProductModel> products = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String? brandName;

      if (data['brandId'] != null) {
        final brandDoc = await _db.collection('brands').doc(data['brandId']).get();
        brandName = brandDoc.data()?['name'];
      }
      products.add(ProductModel.fromSnapshot(doc, brandName));
    }
    return products;
  }

  /// LẤY SẢN PHẨM THEO THƯƠNG HIỆU
  Future<List<ProductModel>> getProductsByBrand({required String brandId}) async {
    final snapshot = await _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('brandId', isEqualTo: brandId)
        .get();

    List<ProductModel> products = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String? brandName;

      if (data['brandId'] != null) {
        final brandDoc = await _db.collection('brands').doc(data['brandId']).get();
        brandName = brandDoc.data()?['name'];
      }
      products.add(ProductModel.fromSnapshot(doc, brandName));
    }
    return products;
  }

  /// LẤY CHI TIẾT 1 SẢN PHẨM QUA ID
  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    String? brandName;

    if (data['brandId'] != null) {
      final brandDoc = await _db.collection('brands').doc(data['brandId']).get();
      brandName = brandDoc.data()?['name'];
    }

    return ProductModel.fromSnapshot(doc, brandName);
  }
}