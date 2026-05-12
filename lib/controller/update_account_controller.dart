import 'dart:io';
import 'package:get/get.dart';
import 'package:ltud_lab/controller/login_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/services/update_account_service.dart';

class UpdateAccountController extends GetxController {
  final UpdateAccountService _service = UpdateAccountService();
  var isUploading = false.obs;

  Future<void> changeName(String fullName) async {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;

    if (user == null) return;

    List<String> parts = fullName.trim().split(' ');
    String firstName = parts.first;
    String lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    await _service.updateName(
      userId: user.id,
      firstName: firstName,
      lastName: lastName,
    );

    authController.currentUser = user.copyWith(
      firstName: firstName,
      lastName: lastName,
    );
    authController.update();
  }

  /// Tải ảnh lên Storage và cập nhật Firestore
  Future<void> uploadAndSaveProfilePicture(File imageFile) async {
    try {
      isUploading.value = true;
      
      // 1. Tải lên Storage lấy URL
      final imageUrl = await _service.uploadImage(imageFile);
      
      // 2. Cập nhật Firestore
      await updateProfilePicture(imageUrl);
      
      Get.snackbar("Thành công", "Đã cập nhật ảnh đại diện mới", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Lỗi", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;
    if (user == null) return;

    await _service.updateProfilePicture(imageUrl);
    
    authController.currentUser = user.copyWith(profilePicture: imageUrl);
    authController.update();
  }

  Future<void> updateUsername(String username) async {
    await _service.updateUsername(username);
  }

  Future<void> updateEmail(String email) async {
    await _service.updateEmail(email);
  }

  Future<void> syncEmailAfterVerification() async {
    await _service.syncEmailAfterVerification();
  }

  Future<void> updateGender(String gender) async {
    await _service.updateGender(gender);
  }

  Future<void> updateDateOfBirth(DateTime date) async {
    await _service.updateDateOfBirth(date);
  }

  Future<void> updatePhone(String phone) async {
    await _service.updatePhone(phone);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserData() {
    return _service.getUserData();
  }
}
