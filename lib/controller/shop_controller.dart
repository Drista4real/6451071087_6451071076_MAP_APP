import 'package:get/get.dart';
import '../data/models/shop_models.dart';
import '../data/services/shop_service.dart';

class ShopController extends GetxController {
  final ShopService _shopService = ShopService();

  List<ShopBanner> banners = const [];
  List<ShopCategory> categories = const [];
  List<ShopProduct> popularProducts = const [];
  List<ShopProduct> filteredProducts = const [];
  List<OrderStatusUpdate> orderUpdates = const [];

  String selectedCategoryId = 'all';
  String keyword = '';
  int cartQuantity = 3;

  @override
  void onInit() {
    super.onInit();
    loadShopData();
  }

  void loadShopData() {
    banners = _shopService.getBanners();
    categories = _shopService.getCategories();
    popularProducts = List<ShopProduct>.from(_shopService.getProducts())
      ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
    orderUpdates = _shopService.getOrderUpdates();
    _applyFilter();
    update();
  }

  void updateSearch(String value) {
    keyword = value.trim().toLowerCase();
    _applyFilter();
    update();
  }

  void selectCategory(String categoryId) {
    selectedCategoryId = categoryId;
    _applyFilter();
    update();
  }

  void _applyFilter() {
    filteredProducts = popularProducts.where((product) {
      final matchCategory = selectedCategoryId == 'all' || product.categoryId == selectedCategoryId;
      final matchKeyword = keyword.isEmpty || product.name.toLowerCase().contains(keyword);
      return matchCategory && matchKeyword;
    }).toList();
  }
}
