class ShopBanner {
  final String imagePath;
  final String title;

  const ShopBanner({required this.imagePath, required this.title});
}

class ShopCategory {
  final String id;
  final String name;
  final String imagePath;

  const ShopCategory({
    required this.id,
    required this.name,
    required this.imagePath,
  });
}

class ShopProduct {
  final String id;
  final String name;
  final double price;
  final String categoryId;
  final String imagePath;
  final int soldCount;

  const ShopProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.imagePath,
    required this.soldCount,
  });
}

class OrderStatusUpdate {
  final String orderCode;
  final String status;
  final DateTime updatedAt;

  const OrderStatusUpdate({
    required this.orderCode,
    required this.status,
    required this.updatedAt,
  });
}
