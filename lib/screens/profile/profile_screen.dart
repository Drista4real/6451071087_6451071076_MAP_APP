import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          /// ===== HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            color: Colors.blue,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Guest User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                /// ===== LOGIN BUTTON =====
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                    // đổi '/login' theo route bạn dùng
                  },
                  child: const Text('Đăng nhập ngay'),
                ),
              ],
            ),
          ),

          /// ===== OPTIONAL CONTENT (có thể bỏ nếu muốn tối giản hơn) =====
          Expanded(
            child: Center(
              child: Text(
                'Vui lòng đăng nhập để sử dụng đầy đủ tính năng',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}