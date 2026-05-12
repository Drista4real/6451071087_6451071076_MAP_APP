import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/styles/app_colors.dart';
import '../../common/styles/app_text_styles.dart';
import '../../common/widgets/profile_menu_item.dart';
import '../../routes/app_routes.dart';
import '../order/my_order_screen.dart';
import '../bank_account/my_bank_account_screen.dart';
import '../notifications/my_notifications.dart';
import '../shipping_address/my_shipping_address_screen.dart';
import 'package:ltud_lab/controller/login_controller.dart';
import 'package:ltud_lab/controller/settings_controller.dart';
import 'package:ltud_lab/controller/update_account_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        bool loggedIn = authController.currentUser != null;
        if (!loggedIn) {
          return _buildGuestProfile(context);
        }
        return _buildUserProfile(context, authController);
      },
    );
  }

  /// ===== Header với chức năng cập nhật ảnh đại diện từ thiết bị =====
  Widget _buildHeader(BuildContext context, AuthController authController) {
    final user = authController.currentUser;
    final updateController = Get.put(UpdateAccountController());
    
    String fullName = user?.fullName ?? 'Người dùng';
    String email = user?.email ?? '';
    String? profilePic = user?.profilePicture;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      color: AppColors.primaryBlue,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showUpdateAvatarOptions(context, updateController),
            child: Stack(
              children: [
                // Hiển thị Avatar với hiệu ứng mờ khi đang upload
                Obx(() => Opacity(
                  opacity: updateController.isUploading.value ? 0.5 : 1.0,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white24,
                    backgroundImage: profilePic != null && profilePic.isNotEmpty
                        ? NetworkImage(profilePic)
                        : NetworkImage('https://ui-avatars.com/api/?name=${fullName.replaceAll(' ', '+')}&background=random') as ImageProvider,
                  ),
                )),
                
                // Hiển thị vòng xoay loading khi đang xử lý
                Obx(() => updateController.isUploading.value
                    ? const Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
                    
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fullName, style: AppTextStyle.whiteTitle),
                const SizedBox(height: 4),
                Text(email, style: AppTextStyle.whiteSubtitle),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.updateAccount);
            },
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, AuthController authController) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context, authController),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountSetting(context),
                    const SizedBox(height: 24),
                    _buildAppSettingLabel(),
                    const SizedBox(height: 16),
                    _buildAppSettings(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSetting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cài đặt tài khoản', style: AppTextStyle.title),
        const SizedBox(height: 16),
        ProfileMenuItem(
          icon: Icons.location_on,
          title: 'Địa chỉ của tôi',
          subtitle: 'Quản lý địa chỉ giao hàng',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyShippingAddressScreen())),
        ),
        ProfileMenuItem(
          icon: Icons.shopping_cart,
          title: 'Giỏ hàng của tôi',
          subtitle: 'Xem các mặt hàng trong giỏ hàng',
          onTap: () => Navigator.pushNamed(context, AppRoutes.cartOverview),
        ),
        ProfileMenuItem(
          icon: Icons.receipt_long,
          title: 'Đơn hàng của tôi',
          subtitle: 'Theo dõi đơn hàng của bạn',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrderScreen())),
        ),
        ProfileMenuItem(
          icon: Icons.account_balance,
          title: 'Tài khoản ngân hàng',
          subtitle: 'Quản lý phương thức thanh toán',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyBankAccountScreen())),
        ),
        ProfileMenuItem(
          icon: Icons.notifications,
          title: 'Thông báo',
          subtitle: 'Cài đặt thông báo',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyNotificationScreen())),
        ),
      ],
    );
  }

  Widget _buildAppSettingLabel() => Text('Cài đặt ứng dụng', style: AppTextStyle.title);

  Widget _buildAppSettings() {
    final SettingsController controller = Get.find();
    return Obx(
      () => Column(
        children: [
          ProfileMenuItem(
            icon: Icons.dark_mode,
            title: 'Giao diện',
            subtitle: _getThemeName(controller.themeMode.value),
            onTap: () => _showThemeDialog(controller),
          ),
          ProfileMenuItem(
            icon: Icons.text_fields,
            title: 'Cỡ chữ',
            subtitle: _getFontSizeName(controller.fontSize.value),
            onTap: () => _showFontDialog(controller),
          ),
          ProfileMenuItem(
            icon: Icons.language,
            title: 'Ngôn ngữ',
            subtitle: controller.locale.value.languageCode == 'vi' ? 'Tiếng Việt' : 'English',
            onTap: () => _showLanguageDialog(controller),
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Sáng';
      case ThemeMode.dark: return 'Tối';
      default: return 'Hệ thống';
    }
  }

  String _getFontSizeName(String size) {
    switch (size) {
      case 'small': return 'Nhỏ';
      case 'large': return 'Lớn';
      default: return 'Vừa';
    }
  }

  Widget _buildLogoutButton(BuildContext context) {
    final AuthController authController = Get.find();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: () async {
          bool? confirm = await Get.defaultDialog<bool>(
            title: "Đăng xuất",
            middleText: "Bạn có chắc chắn muốn đăng xuất không?",
            textConfirm: "Đăng xuất",
            textCancel: "Hủy",
            confirmTextColor: Colors.white,
            onConfirm: () => Get.back(result: true),
          );
          if (confirm == true) {
            await authController.logout();
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('Đăng xuất', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 24),
            const Text('Guest User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                child: const Text('Đăng nhập ngay', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị tùy chọn cập nhật ảnh đại diện (Thư viện hoặc Camera)
  void _showUpdateAvatarOptions(BuildContext context, UpdateAccountController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Cập nhật ảnh đại diện",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text("Chọn từ thư viện"),
              onTap: () async {
                Get.back();
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  await controller.uploadAndSaveProfilePicture(File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text("Chụp ảnh mới"),
              onTap: () async {
                Get.back();
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  await controller.uploadAndSaveProfilePicture(File(image.path));
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(SettingsController controller) {
    Get.defaultDialog(
      title: "Giao diện",
      content: Column(
        children: [
          _buildDialogOption("Sáng", () => controller.changeTheme('light')),
          _buildDialogOption("Tối", () => controller.changeTheme('dark')),
          _buildDialogOption("Hệ thống", () => controller.changeTheme('system')),
        ],
      ),
    );
  }

  void _showFontDialog(SettingsController controller) {
    Get.defaultDialog(
      title: "Cỡ chữ",
      content: Column(
        children: [
          _buildDialogOption("Nhỏ", () => controller.changeFontSize('small')),
          _buildDialogOption("Vừa", () => controller.changeFontSize('medium')),
          _buildDialogOption("Lớn", () => controller.changeFontSize('large')),
        ],
      ),
    );
  }

  void _showLanguageDialog(SettingsController controller) {
    Get.defaultDialog(
      title: "Ngôn ngữ",
      content: Column(
        children: [
          _buildDialogOption("Tiếng Việt", () => controller.changeLanguage('vi')),
          _buildDialogOption("English", () => controller.changeLanguage('en')),
        ],
      ),
    );
  }

  Widget _buildDialogOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, textAlign: TextAlign.center),
      onTap: () {
        onTap();
        Get.back();
      },
    );
  }
}
