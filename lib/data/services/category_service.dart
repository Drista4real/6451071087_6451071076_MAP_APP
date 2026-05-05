import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Lấy danh sách tối đa 10 danh mục đang hoạt động, sắp xếp theo độ ưu tiên
  Future<List<CategoryModel>> getAllCategories() async {
    final snapshot = await _db
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .orderBy('priority')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
  }
}