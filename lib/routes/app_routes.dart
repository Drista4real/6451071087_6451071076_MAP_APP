import 'package:ltud_lab/screens/auth/forget_password_screen.dart';
import 'package:ltud_lab/screens/auth/login_screen.dart';
import 'package:ltud_lab/screens/auth/register_screen.dart';
import 'package:ltud_lab/screens/auth/register_success_screen.dart';
import 'package:ltud_lab/screens/auth/reset_email_sent_screen.dart';
import 'package:ltud_lab/screens/auth/verify_email_screen.dart';
import 'package:ltud_lab/screens/bank_account/my_bank_account_screen.dart';
import 'package:ltud_lab/screens/bank_account/add_edit_bank_account_screen.dart';
import 'package:ltud_lab/screens/cart/cart_overview_screen.dart';
import 'package:ltud_lab/screens/onboarding/onboarding_screen.dart';
import 'package:ltud_lab/screens/order/my_order_screen.dart';
import 'package:ltud_lab/screens/order/order_overview_screen.dart';
import 'package:ltud_lab/screens/order/ordered_detail_screen.dart';
import 'package:ltud_lab/screens/order/order_success_screen.dart';
import 'package:ltud_lab/screens/profile/change_dateofbirth_screen.dart';
import 'package:ltud_lab/screens/profile/change_email_screen.dart';
import 'package:ltud_lab/screens/profile/change_gender_screen.dart';
import 'package:ltud_lab/screens/profile/change_name_screen.dart';
import 'package:ltud_lab/screens/profile/change_password_screen.dart';
import 'package:ltud_lab/screens/profile/change_phonenumber_screen.dart';
import 'package:ltud_lab/screens/profile/change_username_screen.dart';
import 'package:ltud_lab/screens/profile/update_account_screen.dart';
import 'package:ltud_lab/screens/shipping_address/my_shipping_address_screen.dart';
import 'package:ltud_lab/screens/shipping_address/add_edit_address_screen.dart';
import 'package:ltud_lab/screens/notifications/my_notifications.dart';
import 'package:ltud_lab/screens/mystore/all_brand_screen.dart';
import 'package:ltud_lab/screens/mystore/brand_detail_screen.dart';
import 'package:ltud_lab/screens/product/product_detail_screen.dart';
import 'package:ltud_lab/screens/product/popular_product_screen.dart';
import 'package:ltud_lab/screens/product/product_by_subcategory_screen.dart';
import 'package:ltud_lab/screens/admin/firebase_data_management_screen.dart';
import 'package:ltud_lab/data/models/order_model.dart';
import 'package:ltud_lab/data/models/address_model.dart';
import 'package:ltud_lab/data/models/bank_account_model.dart';
import 'package:flutter/material.dart';
import '../screens/home/main_navigation_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgetPassword = '/forget-password';
  static const String resetEmailSent = '/reset-email-sent';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String registerSuccess = '/register-success';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String updateAccount = '/update-account';
  static const String changeName = '/change-name';
  static const String changeUsername = '/change-username';
  static const String changePassword = '/change-password';
  static const String changeEmail = '/change-email';
  static const String changePhoneNumber = '/change-phonenumber';
  static const String changeGender = '/change-gender';
  static const String changeDateofBirth = '/change-datebirth';
  static const String cartOverview = '/cart-overview';
  static const String orderOverview = '/order-overview';
  static const String orderSuccess = '/order-success';
  static const String orderDetail = '/order-detail';
  static const String myOrderview = '/my-order';
  static const String myShippingAddressview = '/my_shipping_address';
  static const String addEditAddress = '/add-edit-address';
  static const String myBankAccountview = '/my_bank_account';
  static const String addEditBankAccount = '/add-edit-bank-account';
  static const String notifications = '/notifications';
  static const String allBrands = '/all-brands';
  static const String brandDetail = '/brand-detail';
  static const String productDetail = '/product-detail';
  static const String popularProducts = '/popular-products';
  static const String productCategory = '/product-category';
  static const String adminFirebase = '/admin-firebase';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    register: (context) => const RegisterScreen(),
    login: (context) => const LoginScreen(),
    forgetPassword: (context) => ForgetPasswordScreen(),
    home: (context) => const MainNavigationScreen(),
    updateAccount: (context) => const UpdateAccountScreen(),
    changeName: (context) => const ChangeNameScreen(),
    changeUsername: (context) => const ChangeUsernameScreen(),
    changePassword: (context) => const ChangePasswordScreen(),
    changeEmail: (context) => const ChangeEmailScreen(),
    changePhoneNumber: (context) => const ChangePhoneNumberScreen(),
    changeGender: (context) => const ChangeGenderScreen(),
    changeDateofBirth: (context) => const ChangeDateOfBirthScreen(),
    cartOverview: (context) => const CartOverviewScreen(),
    orderOverview: (context) => const OrderReviewScreen(),
    orderSuccess: (context) => const OrderSuccessScreen(),
    myOrderview: (context) => const MyOrderScreen(),
    myShippingAddressview: (context) => MyShippingAddressScreen(),
    addEditAddress: (context) {
      final address = ModalRoute.of(context)?.settings.arguments as AddressModel?;
      return EditAddressScreen(address: address);
    },
    myBankAccountview: (context) => MyBankAccountScreen(),
    addEditBankAccount: (context) {
      final bank = ModalRoute.of(context)?.settings.arguments as BankAccountModel?;
      return EditBankAccountScreen(bank: bank);
    },
    notifications: (context) => MyNotificationScreen(),
    allBrands: (context) => AllBrandScreen(),
    popularProducts: (context) => const PopularProductScreen(),
    adminFirebase: (context) => const FirebaseDataManagementScreen(),

    verifyEmail: (context) {
      final String email = ModalRoute.of(context)!.settings.arguments as String;
      return VerifyEmailScreen(email: email);
    },
    registerSuccess: (context) => const RegisterSuccessScreen(),
    resetEmailSent: (context) {
      final email = ModalRoute.of(context)!.settings.arguments as String;
      return ResetEmailSentScreen(email: email);
    },
    orderDetail: (context) {
      final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
      return OrderDetailScreen(order: order);
    },
    brandDetail: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return BrandDetailScreen(
        brandId: args['brandId'],
        brandName: args['brandName'],
      );
    },
    productDetail: (context) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      return ProductDetailScreen(productId: productId);
    },
    productCategory: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return ProductBySubCategoryScreen(
        categoryId: args['categoryId'],
        categoryName: args['categoryName'],
      );
    },
  };
}
