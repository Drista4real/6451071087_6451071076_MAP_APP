import 'package:flutter/material.dart';
import '../../data/services/firebase_data_sender.dart';

class FirebaseDataManagementScreen extends StatefulWidget {
  const FirebaseDataManagementScreen({super.key});

  @override
  State<FirebaseDataManagementScreen> createState() =>
      _FirebaseDataManagementScreenState();
}

class _FirebaseDataManagementScreenState
    extends State<FirebaseDataManagementScreen> {
  final FirebaseDataSender _dataSender = FirebaseDataSender();
  bool _isLoading = false;
  String _connectionStatus = 'Chưa kiểm tra';
  Color _statusColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Dữ Liệu Firebase'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thẻ kiểm tra kết nối - BẮT BỆNH CHÍNH XÁC
            _buildConnectionStatusCard(),
            const SizedBox(height: 20),

            // Nút gửi dữ liệu
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendAllData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.cloud_upload),
              label: const Text('Gửi Dữ Liệu Test', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),

            // Nút xóa dữ liệu
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _showDeleteConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Xóa Dữ Liệu Mẫu', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            _buildDataSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.wifi_tethering, color: _statusColor),
              const SizedBox(width: 10),
              const Expanded(child: Text('Trạng thái Firebase:', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: Colors.black.withOpacity(0.05),
            child: Text(
              _connectionStatus,
              style: TextStyle(color: _statusColor, fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _checkConnection,
              icon: const Icon(Icons.refresh),
              label: const Text('Kiểm Tra Kết Nối'),
              style: OutlinedButton.styleFrom(foregroundColor: _statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Đang ping Firestore...';
      _statusColor = Colors.orange;
    });

    try {
      await _dataSender.checkConnection();
      setState(() {
        _connectionStatus = 'KẾT NỐI THÀNH CÔNG!\nBạn có thể gửi dữ liệu ngay.';
        _statusColor = Colors.green;
      });
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('permission-denied')) {
        errorMsg = 'LỖI QUYỀN (Rules): Bạn chưa mở Rules trong Firebase Console.';
      } else if (errorMsg.contains('not-found')) {
        errorMsg = 'LỖI DATABASE: Bạn chưa nhấn nút "Create Database" trên Web.';
      }
      setState(() {
        _connectionStatus = errorMsg;
        _statusColor = Colors.red;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendAllData() async {
    setState(() => _isLoading = true);
    try {
      await _dataSender.sendAllDataToFirebase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Dữ liệu đã xuất hiện trên Firebase!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi gửi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa?'),
        content: const Text('Dữ liệu mẫu sẽ bị xóa khỏi Firestore.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _deleteAllData(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    setState(() => _isLoading = true);
    try {
      await _dataSender.deleteAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Đã xóa sạch dữ liệu mẫu!'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi xóa: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDataSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📊 Dữ liệu chuẩn bị gửi:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _summaryItem(Icons.image, 'Banners', _dataSender.banners.length),
        _summaryItem(Icons.category, 'Categories', _dataSender.categories.length),
        _summaryItem(Icons.shopping_bag, 'Products', _dataSender.products.length),
        _summaryItem(Icons.local_offer, 'Coupons', _dataSender.coupons.length),
      ],
    );
  }

  Widget _summaryItem(IconData icon, String title, int count) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      trailing: Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      contentPadding: EdgeInsets.zero,
    );
  }
}
