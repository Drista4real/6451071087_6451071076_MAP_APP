import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ltud_lab/controller/login_controller.dart';
import 'package:ltud_lab/controller/shop_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ShopController>()) {
      Get.put(ShopController());
    }

    return GetBuilder<ShopController>(
      builder: (shopController) {
        final authController = Get.isRegistered<AuthController>()
            ? Get.find<AuthController>()
            : null;
        final fullName = authController?.currentUser?.fullName.isNotEmpty == true
            ? authController!.currentUser!.fullName
            : 'Guest User';
        final latestOrder = shopController.orderUpdates.isNotEmpty
            ? shopController.orderUpdates.first
            : null;

        return Scaffold(
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Good day for shopping', style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 4),
                                Text(
                                  fullName,
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: CircleAvatar(
                                  radius: 9,
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    '${shopController.cartQuantity}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (latestOrder != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Cap nhat ${latestOrder.orderCode}: ${latestOrder.status}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: shopController.updateSearch,
                        decoration: InputDecoration(
                          hintText: 'Tim kiem san pham phu kien the thao',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, index) {
                            final category = shopController.categories[index];
                            final selected = category.id == shopController.selectedCategoryId;
                            return ChoiceChip(
                              label: Text(category.name),
                              selected: selected,
                              onSelected: (_) => shopController.selectCategory(category.id),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemCount: shopController.categories.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: shopController.banners.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (_, index) {
                            final banner = shopController.banners[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                banner.imagePath,
                                width: 300,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 300,
                                  color: Colors.grey.shade300,
                                  alignment: Alignment.center,
                                  child: Text(banner.title),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('San pham pho bien', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      GridView.builder(
                        itemCount: shopController.filteredProducts.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.64,
                        ),
                        itemBuilder: (_, index) {
                          final product = shopController.filteredProducts[index];
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                    child: Image.asset(
                                      product.imagePath,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey.shade300,
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.image),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text('\$${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
