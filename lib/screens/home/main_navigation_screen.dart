import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../profile/profile_screen.dart';
import '../mystore/mystore_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../admin/firebase_data_management_screen.dart'; // Thêm import này

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    MystoreScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      // NÚT CAM TẠM THỜI ĐỂ VÀO QUẢN LÝ FIREBASE (NHẤN VÀO ĐÂY SAU KHI CHẠY APP)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FirebaseDataManagementScreen()),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'My store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
