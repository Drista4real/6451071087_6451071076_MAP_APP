import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/brand_model.dart';

class BrandService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// GET ALL FEATURED BRANDS
  Future<List<BrandModel>> getAllFeaturedBrands() async {
    try {
      final snapshot = await _db
          .collection('brands')
          .where('isFeatured', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => BrandModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching featured brands: $e');
      return [];
    }
  }

  /// GET ALL BRANDS
  Future<List<BrandModel>> getAllBrands() async {
    try {
      final snapshot = await _db
          .collection('brands')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => BrandModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching all brands: $e');
      return [];
    }
  }

  /// GET BRAND BY ID
  Future<BrandModel?> getBrandById(String brandId) async {
    try {
      final doc = await _db.collection('brands').doc(brandId).get();
      if (doc.exists) {
        return BrandModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching brand: $e');
      return null;
    }
  }
}