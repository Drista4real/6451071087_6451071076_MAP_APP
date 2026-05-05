import 'package:get/get.dart';
import '../data/models/cart_item_model.dart';
import '../data/services/cart_service.dart';

class CartController extends GetxController {
  final CartService _service = CartService();

  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Khởi tạo dữ liệu từ service nếu có sẵn
    cartItems.assignAll(_service.cart.items);
  }

  /// THÊM VÀO GIỎ HÀNG
  void addToCart(CartItemModel item) {
    _service.addToCart(item);

    /// QUAN TRỌNG: Phải assign lại list để GetX nhận diện thay đổi
    cartItems.assignAll(_service.cart.items);

    Get.snackbar(
      "Thành công",
      "Đã thêm sản phẩm vào giỏ hàng",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// XÓA KHỎI GIỎ HÀNG
  void removeItem(CartItemModel item) {
    _service.removeItem(item);
    cartItems.assignAll(_service.cart.items);
  }

  /// TĂNG SỐ LƯỢNG
  void increaseQty(CartItemModel item) {
    _service.increaseQty(item);
    cartItems.assignAll(_service.cart.items);
  }

  /// GIẢM SỐ LƯỢNG
  void decreaseQty(CartItemModel item) {
    _service.decreaseQty(item);
    cartItems.assignAll(_service.cart.items);
  }

  /// TỔNG TIỀN
  double get totalPrice {
    return cartItems.fold(
      0,
          (sum, item) => sum + (item.finalPrice * item.quantity),
    );
  }

  /// TỔNG SỐ LƯỢNG (Dùng cho Badge trên icon giỏ hàng)
  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// KIỂM TRA BIẾN THỂ TRÙNG NHAU
  bool isInCart(String productId, Map<String, String>? variation) {
    return cartItems.any(
          (item) => item.productId == productId && _isSameVariation(item.selectedVariation, variation),
    );
  }

  bool _isSameVariation(Map<String, String>? a, Map<String, String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  /// KIỂM TRA SẢN PHẨM CÓ TRONG GIỎ KHÔNG (BẤT KỂ BIẾN THỂ)
  bool isProductInCart(String productId) {
    return cartItems.any((item) => item.productId == productId);
  }
}