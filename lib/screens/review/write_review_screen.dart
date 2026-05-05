import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../controller/login_controller.dart';

class WriteReviewScreen extends StatefulWidget {
  final ProductModel product;
  final String? reviewId;

  const WriteReviewScreen({super.key, required this.product, this.reviewId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double rating = 5;
  final TextEditingController reviewController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final auth = Get.find<AuthController>();
  List<String> mediaUrls = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.reviewId != null) {
      loadExistingReview();
    }
  }

  Future<void> loadExistingReview() async {
    setState(() => isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          rating = (data['rating'] ?? 5).toDouble();
          titleController.text = data['title'] ?? "";
          reviewController.text = data['reviewText'] ?? '';
          mediaUrls = List<String>.from(data['mediaUrls'] ?? []);
        });
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải dữ liệu đánh giá");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> submitReview() async {
    final user = auth.currentUser;
    if (user == null) {
      Get.snackbar("Lỗi", "Bạn cần đăng nhập để viết đánh giá");
      return;
    }

    if (titleController.text.trim().isEmpty || reviewController.text.trim().isEmpty) {
      Get.snackbar("Yêu cầu", "Vui lòng điền đầy đủ tiêu đề và nội dung đánh giá",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);
    try {
      final reviewData = {
        'productId': widget.product.id,
        'productName': widget.product.title,
        'productImage': widget.product.thumbnail,
        'userId': user.id,
        'userName': "${user.firstName} ${user.lastName}",
        'rating': rating,
        'title': titleController.text.trim(),
        'reviewText': reviewController.text.trim(),
        'mediaUrls': mediaUrls,
        'updatedAt': Timestamp.now(),
        'isApproved': false, // Chờ Admin duyệt
        'isDeleted': false,
      };

      if (widget.reviewId == null) {
        await FirebaseFirestore.instance.collection('reviews').add({
          ...reviewData,
          'createdAt': Timestamp.now(),
        });
      } else {
        await FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId).update(reviewData);
      }

      await updateProductRating();
      Get.back();
      Get.snackbar("Thành công", "Đánh giá của bạn đã được gửi và đang chờ duyệt",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Lỗi", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProductRating() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('productId', isEqualTo: widget.product.id)
        .where('isApproved', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc['rating'] ?? 0).toDouble();
    }
    final count = snapshot.docs.length;
    final avg = count == 0 ? 0.0 : total / count;

    await FirebaseFirestore.instance.collection('products').doc(widget.product.id).update({
      'rating': avg,
      'ratingCount': count,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.reviewId == null ? "Viết đánh giá" : "Sửa đánh giá",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(widget.product.thumbnail, width: 60, height: 60, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(widget.product.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
            const Center(child: Text("Bạn đánh giá sản phẩm này thế nào?",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => rating = index + 1.0),
                  child: Icon(
                    index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 48, color: Colors.amber,
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            const Text("Tiêu đề đánh giá", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Điều quan trọng nhất là gì?",
                filled: true, fillColor: Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Nội dung đánh giá", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Bạn thích hay không thích điều gì ở sản phẩm?",
                filled: true, fillColor: Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 25),
            const Text("Thêm hình ảnh", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: _showAddImageDialog,
                    child: Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ...mediaUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(url, width: 90, height: 90, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 4, top: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => mediaUrls.remove(url)),
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(widget.reviewId == null ? "Gửi đánh giá" : "Cập nhật đánh giá",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddImageDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thêm link ảnh"),
        content: TextField(controller: urlController, autofocus: true, decoration: const InputDecoration(hintText: "Dán URL hình ảnh vào đây...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                setState(() => mediaUrls.add(urlController.text.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }
}