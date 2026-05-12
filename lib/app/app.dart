import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../controller/settings_controller.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final SettingsController settingsController = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Tính toán tỷ lệ font chữ dựa trên cài đặt
      double textScale = 1.0;
      if (settingsController.fontSize.value == 'small') {
        textScale = 0.85;
      } else if (settingsController.fontSize.value == 'large') {
        textScale = 1.2;
      }

      return GetMaterialApp(
        title: 'FitZone E-Commerce',
        debugShowCheckedModeBanner: false,
        // NGÔN NGỮ
        locale: settingsController.locale.value,
        // GIAO DIỆN (THEME)
        themeMode: settingsController.themeMode.value,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            foregroundColor: Colors.black,
          ),
        ),
        darkTheme: ThemeData.dark(useMaterial3: true),
        
        // CẤU HÌNH CỠ CHỮ TOÀN ỨNG DỤNG
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          );
        },

        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      );
    });
  }
}
