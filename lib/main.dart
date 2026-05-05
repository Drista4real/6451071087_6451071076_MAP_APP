import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'controller/login_controller.dart';
import 'controller/cart_controller.dart';
import 'controller/notification_controller.dart';
import 'controller/order_controller.dart';
import 'controller/wishlist_controller.dart';
import 'controller/settings_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(AuthController());
  Get.put(NotificationController());
  Get.put(CartController());
  Get.put(OrderController());
  Get.put(WishlistController());
  Get.put(SettingsController());

  runApp(MyApp());
}