import 'package:fitness_social_app/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the login form by default', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthPage()));

    expect(find.text('مرحباً بعودتك'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('أنشئ حساباً'), findsOneWidget);
  });
}
