import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  Future<List<dynamic>> fetchCities() async {
    final response = await http.get(
      Uri.parse('https://provinces.open-api.vn/api/v2/?depth=2'),
    );

    if (response.statusCode == 200) {
      // API này trả về trực tiếp một List các tỉnh thành
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể lấy danh sách tỉnh thành');
    }
  }
}