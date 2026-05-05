import '/data/models/cart_model.dart';
import '/data/models/cart_item_model.dart';

class CartService {
  final CartModel _cart = CartModel.empty();

  CartModel get cart => _cart;

  /// THÊM VÀO GIỎ HÀNG
  void addToCart(CartItemModel item) {
    final index = _cart.items.indexWhere(
          (e) => e.productId == item.productId && _isSameVariation(e.selectedVariation, item.selectedVariation),
    );

    if (index >= 0) {
      // Nếu đã có trong giỏ thì cộng dồn số lượng
      _cart.items[index].quantity += item.quantity;
    } else {
      // Nếu chưa có thì thêm mới vào list
      _cart.items.add(item);
    }
  }

  /// XÓA MÓN HÀNG
  void removeItem(CartItemModel item) {
    _cart.items.remove(item);
  }

  /// TĂNG SỐ LƯỢNG
  void increaseQty(CartItemModel item) {
    item.quantity++;
  }

  /// GIẢM SỐ LƯỢNG
  void decreaseQty(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      // Nếu số lượng bằng 1 mà giảm tiếp thì xóa luôn khỏi giỏ
      _cart.items.remove(item);
    }
  }

  /// SO SÁNH BIẾN THỂ (Màu sắc, kích cỡ...)
  bool _isSameVariation(Map<String, String>? a, Map<String, String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}