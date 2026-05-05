import 'dart:async';
import 'package:get/get.dart';
import '../data/models/product_model.dart';
import '../data/services/product_service.dart';

class ProductController extends GetxController {
  final ProductService _service = ProductService();

  var products = <ProductModel>[].obs;
  var popularProducts = <ProductModel>[].obs;
  var categoryProducts = <ProductModel>[].obs;
  var searchResults = <ProductModel>[].obs;
  var selectedProduct = Rxn<ProductModel>();

  List<ProductModel> _originalPopularProducts = [];
  List<ProductModel> _originalCategoryProducts = [];

  var isLoading = false.obs;
  var searchQuery = ''.obs;
  Timer? _debounce;

  @override
  void onInit() {
    fetchPopularProducts();
    super.onInit();
  }

  /// LẤY SẢN PHẨM PHỔ BIẾN (TRANG CHỦ)
  Future<void> fetchPopularProducts() async {
    try {
      isLoading.value = true;
      final result = await _service.getPopularProducts();
      products.assignAll(result);
    } catch (e) {
      print("Error loading products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// LẤY TẤT CẢ SẢN PHẨM PHỔ BIẾN
  Future<void> fetchAllPopularProducts() async {
    try {
      isLoading.value = true;
      final result = await _service.getAllPopularProducts();
      _originalPopularProducts = result;
      popularProducts.assignAll(result);
    } catch (e) {
      print("Error loading popular products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// LẤY SẢN PHẨM THEO DANH MỤC
  Future<void> fetchProductsByCategory({required String categoryId}) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      final result = await _service.getProductsByCategory(categoryId: categoryId);
      _originalCategoryProducts = result;
      categoryProducts.assignAll(result);
    } catch (e) {
      print("Error loading category products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// CHI TIẾT SẢN PHẨM
  Future<void> fetchProductDetail(String productId) async {
    try {
      isLoading.value = true;
      final result = await _service.getProductById(productId);
      selectedProduct.value = result;
    } catch (e) {
      print("Error loading product detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// SẮP XẾP SẢN PHẨM PHỔ BIẾN
  void sortPopularProducts(String sortType) {
    List<ProductModel> sorted = List.from(_originalPopularProducts);
    if (sortType == "low_price") {
      sorted.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortType == "high_price") {
      sorted.sort((a, b) => b.price.compareTo(a.price));
    } else {
      sorted.sort((a, b) => a.title.compareTo(b.title));
    }
    popularProducts.assignAll(sorted);
  }

  /// SẮP XẾP SẢN PHẨM THEO DANH MỤC
  void sortCategoryProducts(String sortType) {
    List<ProductModel> sortedList = List.from(_originalCategoryProducts);
    if (sortType == "low_price") {
      sortedList.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortType == "high_price") {
      sortedList.sort((a, b) => b.price.compareTo(a.price));
    } else {
      sortedList.sort((a, b) => a.title.compareTo(b.title));
    }
    categoryProducts.assignAll(sortedList);
  }

  /// LOGIC TÌM KIẾM SẢN PHẨM
  void searchProducts(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    final lowerQuery = query.toLowerCase().trim();
    final results = products.where((product) {
      if (!product.isActive || product.isDeleted) return false;
      final matchTitle = product.lowerTitle.contains(lowerQuery);
      final matchBrand = product.brandName?.toLowerCase().contains(lowerQuery) ?? false;
      final matchTags = product.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      return matchTitle || matchBrand || matchTags;
    }).toList();

    // Sắp xếp thứ tự ưu tiên trong kết quả tìm kiếm
    results.sort((a, b) {
      final aStarts = a.lowerTitle.startsWith(lowerQuery);
      final bStarts = b.lowerTitle.startsWith(lowerQuery);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;
      return b.soldQuantity.compareTo(a.soldQuantity); // Ưu tiên hàng bán chạy
    });

    searchResults.assignAll(results);
  }

  /// XỬ LÝ DEBOUNCE KHI GÕ PHÍM
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchProducts(query);
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}