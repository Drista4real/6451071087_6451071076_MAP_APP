import 'package:get/get.dart';
import '../data/models/category_model.dart';
import '../data/services/category_service.dart';

class CategoryController extends GetxController {
  final CategoryService _service = CategoryService();

  var categories = <CategoryModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  /// Lấy danh sách toàn bộ danh mục sản phẩm từ Service
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final result = await _service.getAllCategories();

      // Cập nhật danh sách quan sát (Reactive List)
      categories.assignAll(result);
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      isLoading.value = false;
    }
  }
}