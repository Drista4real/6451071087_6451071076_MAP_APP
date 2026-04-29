import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ltud_lab/screens/home/home_screen.dart';

void main() {
  testWidgets('Home screen renders shop sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('Good day for shopping'), findsOneWidget);
    expect(find.text('San pham pho bien'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
