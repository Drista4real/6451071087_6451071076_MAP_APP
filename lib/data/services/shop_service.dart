import '../models/shop_models.dart';

class ShopService {
  List<ShopBanner> getBanners() {
    return const [
      ShopBanner(imagePath: 'assets/images/banners/banner_1.jpg', title: 'Flash Sale 30%'),
      ShopBanner(imagePath: 'assets/images/banners/banner_2.jpg', title: 'Sport Accessory Week'),
      ShopBanner(imagePath: 'assets/images/banners/banner_3.jpg', title: 'New Arrivals'),
    ];
  }

  List<ShopCategory> getCategories() {
    return const [
      ShopCategory(id: 'all', name: 'Tat ca', imagePath: 'assets/images/banners/banner_4.jpg'),
      ShopCategory(id: 'ball', name: 'Bong', imagePath: 'assets/images/banners/banner_5.jpg'),
      ShopCategory(id: 'shoe', name: 'Giay', imagePath: 'assets/images/banners/banner_6.jpg'),
      ShopCategory(id: 'bag', name: 'Tui tap', imagePath: 'assets/images/banners/banner_7.jpg'),
      ShopCategory(id: 'protect', name: 'Bao ho', imagePath: 'assets/images/banners/banner_8.jpg'),
    ];
  }

  List<ShopProduct> getProducts() {
    return const [
      ShopProduct(id: 'p1', name: 'Bong da Pro League', price: 22.0, categoryId: 'ball', imagePath: 'assets/images/banners/banner_1.jpg', soldCount: 180),
      ShopProduct(id: 'p2', name: 'Giay chay bo Air Run', price: 79.0, categoryId: 'shoe', imagePath: 'assets/images/banners/banner_2.jpg', soldCount: 320),
      ShopProduct(id: 'p3', name: 'Tui gym Flex 35L', price: 35.0, categoryId: 'bag', imagePath: 'assets/images/banners/banner_3.jpg', soldCount: 145),
      ShopProduct(id: 'p4', name: 'Bang goi the thao', price: 12.0, categoryId: 'protect', imagePath: 'assets/images/banners/banner_4.jpg', soldCount: 210),
      ShopProduct(id: 'p5', name: 'Vo bong ro Grip', price: 10.0, categoryId: 'ball', imagePath: 'assets/images/banners/banner_5.jpg', soldCount: 260),
      ShopProduct(id: 'p6', name: 'Giay da banh Speed X', price: 95.0, categoryId: 'shoe', imagePath: 'assets/images/banners/banner_6.jpg', soldCount: 300),
    ];
  }

  List<OrderStatusUpdate> getOrderUpdates() {
    return [
      OrderStatusUpdate(orderCode: 'DH1024', status: 'Don hang da duoc giao cho don vi van chuyen', updatedAt: DateTime.now().subtract(const Duration(minutes: 20))),
      OrderStatusUpdate(orderCode: 'DH1008', status: 'Don hang da giao thanh cong', updatedAt: DateTime.now().subtract(const Duration(hours: 3))),
    ];
  }
}
