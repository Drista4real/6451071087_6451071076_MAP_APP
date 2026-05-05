import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ltud_lab/controller/cart_controller.dart';
import 'package:ltud_lab/controller/login_controller.dart';
import 'package:ltud_lab/controller/wishlist_controller.dart';
import '../../data/models/product_model.dart';
import '../../screens/product/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final wishlistController = Get.find<WishlistController>();

    /// ================= LOGIC TÍNH TOÁN =================
    final bool isOutOfStock = product.isOutOfStock == true ||
        product.stock <= 0 ||
        product.soldQuantity >= product.stock;

    final bool hasDiscount = product.salePrice != null && product.salePrice! > 0;
    final double discountPercent = hasDiscount ? product.salePrice! : 0;
    final double originalPrice = hasDiscount
        ? product.price / (1 - discountPercent / 100)
        : product.price;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Get.to(() => ProductDetailScreen(productId: product.id));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= PHẦN HÌNH ẢNH =================
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: Image.network(
                      product.thumbnail,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[100],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                /// OVERLAY HẾT HÀNG
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "HẾT HÀNG",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),

                /// BADGE GIẢM GIÁ
                if (hasDiscount && !isOutOfStock)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "-${discountPercent.toStringAsFixed(0)}%",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ),

                /// NÚT YÊU THÍCH
                Positioned(
                  top: 4,
                  right: 4,
                  child: Obx(() {
                    final isFav = wishlistController.isInWishlist(product.id);
                    return IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFav ? Colors.red : Colors.grey[400],
                      ),
                      onPressed: () async {
                        final authController = Get.find<AuthController>();
                        if (authController.currentUser == null) {
                          _showLoginDialog();
                          return;
                        }
                        await wishlistController.toggleWishlist(product);
                      },
                    );
                  }),
                ),
              ],
            ),

            /// ================= PHẦN NỘI DUNG =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brandName?.toUpperCase() ?? 'DỤNG CỤ THỂ HÌNH',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, height: 1.2),
                    ),
                    const Spacer(),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "\$${product.price.toStringAsFixed(0)}",
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 4),
                          Text(
                            "\$${originalPrice.toStringAsFixed(0)}",
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, size: 12, color: Colors.orange),
                            const SizedBox(width: 2),
                            Text("${product.rating}", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                          ],
                        ),
                        Obx(() {
                          final isAdded = cartController.isProductInCart(product.id);
                          return isAdded
                              ? const Icon(Icons.check_circle, size: 16, color: Colors.green)
                              : const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginDialog() {
    Get.defaultDialog(
      title: "Yêu cầu đăng nhập",
      middleText: "Vui lòng đăng nhập để thực hiện chức năng này",
      textConfirm: "Đăng nhập",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      onConfirm: () {
        Get.back();
        Get.toNamed('/login');
      },
    );
  }
}