import 'dart:async';
import 'package:flutter/material.dart';

class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  late PageController pageController;
  late Timer autoSlideTimer;
  int currentIndex = 0;

  final List<String> bannerImages = [
    'assets/images/banners/banner_1.jpg',
    'assets/images/banners/banner_2.jpg',
    'assets/images/banners/banner_3.jpg',
    'assets/images/banners/banner_4.jpg',
    'assets/images/banners/banner_5.jpg',
    'assets/images/banners/banner_6.jpg',
    'assets/images/banners/banner_7.jpg',
    'assets/images/banners/banner_8.jpg',
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);

    // Thiết lập tự động chuyển banner sau mỗi 3 giây
    autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (currentIndex < bannerImages.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }

      if (pageController.hasClients) {
        pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    autoSlideTimer.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// BANNER SLIDER
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: pageController,
            itemCount: bannerImages.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(bannerImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        /// INDICATOR (Dấu chấm nhỏ dưới banner)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(bannerImages.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: currentIndex == index ? 16 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: currentIndex == index ? Colors.blue : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}