# Hướng Dẫn Gửi Dữ Liệu Firebase

## 📋 Tổng Quan

File `firebase_data_sender.dart` chứa tất cả dữ liệu test cho dự án e-commerce gym/thể hình bao gồm:

- **3 Banners**: Khuyến mãi mùa hè, Dụng cụ mới, Giảm giá máy tập.
- **5 Danh Mục**: Tạ & Barbell, Máy Tập, Xà Đơn & Kéo, Ghế & Ghế Tập, Dây Kéo & Lò Xo.
- **5 Thương Hiệu**: PowerFlex Pro, IronMuscle, FitGear Elite, StrengthMax, AthleticPro.
- **16 Sản Phẩm**: Từ tạ tay đến máy tập chuyên nghiệp.
- **4 Mã Giảm Giá**: Với các mức giảm khác nhau.

## 🚀 Cách Sử Dụng

### Cách 1: Sử Dụng Màn Hình Quản Lý (Khuyên dùng)

Màn hình `FirebaseDataManagementScreen` cung cấp giao diện trực quan để nhấn nút gửi hoặc xóa dữ liệu.

#### Bước 1: Đăng ký route (nếu chưa có)
Thêm vào file cấu hình route của bạn (ví dụ: `app_routes.dart` hoặc `app_pages.dart`):

```dart
'/admin-firebase': (context) => const FirebaseDataManagementScreen(),
```

#### Bước 2: Truy cập
Sử dụng `Navigator.pushNamed(context, '/admin-firebase')` để mở màn hình quản lý.

### Cách 2: Gọi Trực Tiếp Trong Code

```dart
import 'package:ltud_lab/data/services/firebase_data_sender.dart';

final dataSender = FirebaseDataSender();

// Gửi tất cả
await dataSender.sendAllDataToFirebase();

// Hoặc gửi lẻ
await dataSender.sendBanners();
await dataSender.sendCategories();
// ...
```

## 📊 Cấu Trúc Dữ Liệu

### Collections trong Firestore:

1. `banners`: Banner quảng cáo trang chủ.
2. `categories`: Danh mục sản phẩm.
3. `brands`: Thương hiệu.
4. `products`: Thông tin sản phẩm chi tiết.
5. `coupons`: Mã giảm giá.

## 🗑️ Xóa Dữ Liệu

Hàm `deleteAllData()` trong `FirebaseDataSender` sẽ xóa các document dựa trên ID mẫu đã định nghĩa. Lưu ý: Nó không xóa toàn bộ collection nếu có dữ liệu khác không nằm trong danh sách mẫu.

## 🐛 Xử Lý Lỗi

1. **Permission Denied**: Kiểm tra Firestore Rules (nên để `allow read, write: if true;` trong quá trình phát triển).
2. **Firebase not initialized**: Đảm bảo đã gọi `Firebase.initializeApp()` trong `main.dart`.
3. **Mạng chậm**: Quá trình gửi 16+ sản phẩm có thể mất vài giây.

---
*Ghi chú: Dữ liệu này chỉ phục vụ mục đích demo/testing.*
