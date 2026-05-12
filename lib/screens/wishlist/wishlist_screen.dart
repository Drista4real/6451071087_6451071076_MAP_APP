import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ltud_lab/routes/app_routes.dart';
import 'package:ltud_lab/controller/login_controller.dart';
import 'package:ltud_lab/controller/wishlist_controller.dart';
import 'package:ltud_lab/controller/cart_controller.dart';
import 'package:ltud_lab/data/models/product_model.dart';
import 'package:ltud_lab/data/models/cart_item_model.dart';
import '../product/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final WishlistController wishlistController = Get.find<WishlistController>();
    final CartController cartController = Get.put(CartController());

    bool loggedIn = authController.currentUser != null;

    if (!loggedIn) {
      return _buildLoginRequired(context);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Danh sách yêu thích',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.blue.shade400],
            ),
          ),
        ),
        actions: [
          Obx(() {
            if (wishlistController.items.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: "Xóa tất cả",
                onPressed: () => _showClearConfirmation(context, wishlistController),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (wishlistController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = wishlistController.items;
        if (items.isEmpty) {
          return _buildEmpty(context);
        }

        return RefreshIndicator(
          onRefresh: () => wishlistController.loadWishlist(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.58, // Điều chỉnh để đủ chỗ cho nút Add to Cart
            ),
            itemBuilder: (context, index) {
              final product = items[index];
              return _WishlistProductCard(
                product: product,
                onRemove: () => wishlistController.removeItem(product.id),
                onAddToCart: () {
                  final cartItem = CartItemModel(
                    productId: product.id,
                    quantity: 1,
                    title: product.title,
                    price: product.price,
                    image: product.thumbnail,
                    brandName: product.brandName,
                  );
                  cartController.addToCart(cartItem);
                },
              );
            },
          ),
        );
      }),
    );
  }

  void _showClearConfirmation(BuildContext context, WishlistController controller) {
    Get.defaultDialog(
      title: "Xác nhận",
      middleText: "Bạn có chắc chắn muốn xóa toàn bộ danh sách yêu thích không?",
      textConfirm: "Xóa hết",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.clearWishlist();
        Get.back();
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_outline_rounded,
              size: 80,
              color: Colors.red.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Danh sách đang trống',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Hãy thêm những sản phẩm bạn yêu thích vào đây!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Mua sắm ngay'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline_rounded, size: 80, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 32),
            const Text(
              'Yêu cầu đăng nhập',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vui lòng đăng nhập để xem và quản lý\ndanh sách yêu thích của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Đăng nhập ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _WishlistProductCard({
    required this.product,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = product.salePrice != null && product.salePrice! > 0;

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailScreen(productId: product.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ẢNH SẢN PHẨM
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "-${product.salePrice!.toStringAsFixed(0)}%",
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite, color: Colors.red, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            /// THÔNG TIN & NÚT BẤM
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.brandName ?? 'FitZone',
                      style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${product.price.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                        IconButton(
                          onPressed: onAddToCart,
                          icon: const Icon(Icons.add_shopping_cart, size: 20, color: Colors.blueAccent),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        )
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
}
