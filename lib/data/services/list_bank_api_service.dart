import 'dart:convert';
import 'package:http/http.dart' as http;

class BankApiService {
  Future<List<dynamic>> fetchBanks() async {
    final response = await http.get(
      Uri.parse('https://api.vietqr.io/v2/banks'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Không thể lấy danh sách ngân hàng từ API');
    }
  }
}