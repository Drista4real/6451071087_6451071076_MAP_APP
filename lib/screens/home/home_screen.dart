import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/home_banner_slider.dart';
import '../../common/widgets/product_card.dart';
import '../../controller/cart_controller.dart';
import '../../controller/notification_controller.dart';
import '../../controller/login_controller.dart';
import '../../controller/category_controller.dart';
import '../../controller/product_controller.dart';
import '../notifications/my_notifications.dart';
import '../product/product_by_subcategory_screen.dart';
import '../cart/cart_overview_screen.dart';
import '../product/popular_product_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final CategoryController categoryController = Get.put(CategoryController());
  final ProductController productController = Get.put(ProductController());
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        // Lấy thông tin người dùng
        final user = authController.currentUser;
        String fullName = (user != null) ? '${user.firstName} ${user.lastName}' : 'Guest User';

        return Scaffold(
          body: Column(
            children: [
              /// ================= TOP BLUE HEADER =================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Good day for shopping', style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text(fullName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Spacer(),

                          /// Icon Thông báo
                          if (authController.currentUser != null)
                            Obx(() {
                              final notificationController = Get.find<NotificationController>();
                              return Stack(
                                children: [
                                  IconButton(
                                    onPressed: () => Get.to(() => MyNotificationScreen()),
                                    icon: const Icon(Icons.notifications, color: Colors.white),
                                  ),
                                  if (notificationController.unreadCount.value > 0)
                                    Positioned(
                                      right: 6, top: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: Text(
                                          notificationController.unreadCount.value.toString(),
                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),

                          /// Icon Giỏ hàng
                          Obx(() => Stack(
                            children: [
                              IconButton(
                                onPressed: () => Get.to(() => const CartOverviewScreen()),
                                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                              ),
                              if (cartController.totalItems > 0)
                                Positioned(
                                  right: 6, top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    child: Text(
                                      cartController.totalItems.toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                            ],
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (value) => productController.onSearchChanged(value),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm dụng cụ thể hình...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Danh mục phổ biến', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 95,
                        child: Obx(() {
                          if (categoryController.isLoading.value) {
                            return const Center(child: CircularProgressIndicator(color: Colors.white));
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryController.categories.length,
                            itemBuilder: (context, index) {
                              final category = categoryController.categories[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: GestureDetector(
                                  onTap: () => Get.to(() => ProductBySubCategoryScreen(categoryId: category.id, categoryName: category.name)),
                                  child: Column(
                                    children: [
                                      CircleAvatar(radius: 30, backgroundColor: Colors.white, backgroundImage: NetworkImage(category.imageURL)),
                                      const SizedBox(height: 6),
                                      Text(category.name, style: const TextStyle(color: Colors.white, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              /// ================= CONTENT AREA =================
              Expanded(
                child: Obx(() {
                  // --- CHẾ ĐỘ TÌM KIẾM ---
                  if (productController.searchQuery.isNotEmpty) {
                    if (productController.searchResults.isEmpty) {
                      return const Center(child: Text("Không tìm thấy sản phẩm"));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: productController.searchResults.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.58,
                      ),
                      itemBuilder: (context, index) => ProductCard(product: productController.searchResults[index]),
                    );
                  }

                  // --- CHẾ ĐỘ BÌNH THƯỜNG ---
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HomeBannerSlider(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Text('Sản phẩm phổ biến', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            TextButton(onPressed: () => Get.to(() => const PopularProductScreen()), child: const Text('Xem tất cả')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (productController.isLoading.value)
                          const Center(child: CircularProgressIndicator())
                        else
                          GridView.builder(
                            itemCount: productController.products.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.58,
                            ),
                            itemBuilder: (context, index) => ProductCard(product: productController.products[index]),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}