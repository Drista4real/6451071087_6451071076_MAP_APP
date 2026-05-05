import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ltud_lab/controller/cart_controller.dart';
import 'package:ltud_lab/controller/login_controller.dart';
import 'package:ltud_lab/data/models/address_model.dart';
import 'package:ltud_lab/data/models/coupon_model.dart';
import 'package:ltud_lab/data/models/order_model.dart';
import 'package:ltud_lab/data/services/order_service.dart';
import 'package:ltud_lab/screens/order/order_success_screen.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  /// ================= CONTROLLER =================
  final cart = Get.find<CartController>();
  final auth = Get.find<AuthController>();

  /// ================= STATE =================
  RxList items = [].obs;
  RxDouble subTotal = 0.0.obs;
  RxDouble tax = 0.0.obs;
  RxDouble shippingFee = 0.0.obs;
  RxDouble discountAmount = 0.0.obs;
  Rxn<CouponModel> coupon = Rxn<CouponModel>();
  Rxn<AddressModel> selectedAddress = Rxn<AddressModel>();
  RxList<AddressModel> addresses = <AddressModel>[].obs;
  RxString phone = "".obs;
  RxString paymentMethod = "cash".obs; // cash | bank

  /// ================= INIT =================
  void loadFromCart() {
    items.assignAll(cart.cartItems);
    subTotal.value = items.fold(0, (sum, e) => sum + (e.price * e.quantity));
    _calculateTax();
  }

  void _calculateTax() {
    tax.value = subTotal.value * 0.1;
  }

  /// ================= SHIPPING =================
  Future calculateShipping(double distanceKm) async {
    shippingFee.value = distanceKm * 5000; // 5k/km
  }

  /// ================= COUPON =================
  Future applyCoupon(String code) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: code.trim())
          .get();

      if (snapshot.docs.isEmpty) {
        Get.snackbar("Error", "Coupon không tồn tại");
        return;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();
      final c = CouponModel.fromJson({
        ...data,
        'id': doc.id,
      });
      final now = DateTime.now();

      /// ===== VALIDATE =====
      if (!c.isActive) {
        Get.snackbar("Error", "Coupon chưa active");
        return;
      }
      if (c.startDate != null && now.isBefore(c.startDate!)) {
        Get.snackbar("Error", "Chưa tới ngày sử dụng");
        return;
      }
      if (c.endDate != null && now.isAfter(c.endDate!)) {
        Get.snackbar("Error", "Coupon đã hết hạn");
        return;
      }
      if (c.usageLimit != -1 && c.usageCount >= c.usageLimit) {
        Get.snackbar("Error", "Coupon đã hết lượt");
        return;
      }

      /// ===== CALCULATE DISCOUNT =====
      double discount = 0;
      if (c.discountType == DiscountType.percentage) {
        discount = subTotal.value * c.discountValue / 100;
      } else {
        discount = c.discountValue;
      }

      coupon.value = c;
      discountAmount.value = discount;
      Get.snackbar("Success", "Áp dụng coupon thành công");
    } catch (e) {
      Get.snackbar("Error", "Lỗi coupon: $e");
    }
  }

  /// ================= TOTAL =================
  double get total {
    return subTotal.value +
        tax.value +
        shippingFee.value -
        discountAmount.value;
  }

  /// ================= ADDRESS =================
  Future fetchAddresses() async {
    if (auth.currentUser == null) return;
    phone.value = auth.currentUser?.phone ?? "";
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.id)
        .collection('addresses')
        .get();
    addresses.assignAll(snapshot.docs
        .map((e) => AddressModel.fromMap(e.id, e.data()))
        .toList());
  }

  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  /// ================= CREATE ORDER =================
  Future createOrder() async {
    final int shipping = cart.cartItems.length;
    if (selectedAddress.value == null) {
      Get.snackbar("Error", "Vui lòng chọn địa chỉ");
      return;
    }
    try {
      final totalAmount = total;
      final order = OrderModel(
        docId: '',
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: auth.currentUser!.id,
        userDeviceToken: '',
        products: items,
        subTotal: subTotal.value,
        shippingAmount: shipping,
        taxRate: 0.1,
        taxAmount: tax.value,
        coupon: coupon.value,
        couponDiscountAmount: discountAmount.value,
        pointsUsed: 0,
        pointsDiscountAmount: 0,
        totalDiscountAmount: discountAmount.value,
        totalAmount: totalAmount,
        paymentStatus: "pending",
        orderStatus: "created",
        orderDate: DateTime.now(),
        shippingAddress: selectedAddress.value!.toMap(),
        activities: [],
        itemCount: items.length,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        paymentMethod: paymentMethod.value,
        paymentMethodType: paymentMethod.value == "bank"
            ? PaymentMethods.bank
            : PaymentMethods.cash,
      );

      await FirebaseFirestore.instance.collection('orders').add(order.toJson() as Map<String, dynamic>);

      await updateSoldQuantityAfterOrder();
      await increaseCouponUsage();

      cart.cartItems.clear();
      Get.offAll(() => const OrderSuccessScreen());
    } catch (e) {
      Get.snackbar("Error", "Tạo đơn thất bại: $e");
    }
  }

  /// ================= COUPON USAGE =================
  Future increaseCouponUsage() async {
    if (coupon.value == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('coupons')
        .where('code', isEqualTo: coupon.value!.code)
        .get();
    if (snapshot.docs.isEmpty) return;
    final docId = snapshot.docs.first.id;
    await FirebaseFirestore.instance.collection('coupons').doc(docId).update({
      'usageCount': FieldValue.increment(1),
    });
  }

  /// ================= DISTANCE =================
  double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  ///////==================
  RxList myOrders = [].obs;
  RxBool isLoadingOrders = false.obs;
  final orderService = OrderService();

  Future fetchMyOrders() async {
    try {
      isLoadingOrders.value = true;
      if (auth.currentUser == null) return;
      final userId = auth.currentUser!.id;
      final orders = await orderService.getOrdersByUser(userId);
      myOrders.assignAll(orders);
    } catch (e) {
      Get.snackbar("Error", "Không load được orders: $e");
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future cancelOrder(String orderId) async {
    await FirebaseFirestore.instance.collection("orders").doc(orderId).update({
      "orderStatus": "cancelled",
      "updatedAt": DateTime.now(),
    });
  }

  Future canReviewProduct(String productId) async {
    if (auth.currentUser == null) return false;
    final userId = auth.currentUser!.id;
    final purchased = await orderService.hasUserPurchasedProduct(
      userId: userId,
      productId: productId,
    );
    if (!purchased) return false;
    final alreadyReviewed = await hasUserReviewedProduct(
      userId: userId,
      productId: productId,
    );
    return !alreadyReviewed;
  }

  Future hasUserReviewedProduct({
    required String userId,
    required String productId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .where('isDeleted', isEqualTo: false)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future updateSoldQuantityAfterOrder() async {
    final firestore = FirebaseFirestore.instance;
    for (var item in items) {
      final docRef = firestore.collection('products').doc(item.productId);
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        final data = snapshot.data()!;
        final int currentSold = data['soldQuantity'] ?? 0;
        final int stock = data['stock'] ?? 0;
        final int newSold = (currentSold + (item.quantity as int)).toInt();
        final bool isOutOfStock = newSold >= stock;
        transaction.update(docRef, {
          'soldQuantity': newSold,
          'isOutOfStock': isOutOfStock,
        });
      });
    }
  }

  Future revertSoldQuantity(OrderModel order) async {
    for (var item in order.products) {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(item.productId)
          .update({'soldQuantity': FieldValue.increment(-item.quantity)});
    }
  }
}