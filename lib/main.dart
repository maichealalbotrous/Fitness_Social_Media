import 'package:fitness_social_app/features/user/presentation/pages/feed_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FitnessSocialApp());
}

class FitnessSocialApp extends StatelessWidget {
  const FitnessSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repflow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF030403),
        fontFamily: 'Arial',
      ),
      home: const FeedPage(),
    );
  }
}
