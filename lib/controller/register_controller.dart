import '../data/models/user_model.dart';
import '../data/services/register_auth_service.dart';

class RegisterController {
  final AuthService _authService = AuthService();

  Future<String?> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      UserModel userModel = UserModel(
        id: "",
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phone: phone,
      );

      await _authService.registerUser(userModel: userModel, password: password);

      return null; // Trả về null nghĩa là đăng ký thành công, không có lỗi
    } catch (e) {
      return e.toString(); // Trả về câu thông báo lỗi nếu có
    }
  }
}
