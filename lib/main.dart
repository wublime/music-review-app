// Run: flutter run (or flutter run -d chrome for web)
import 'package:flutter/material.dart';
import 'screens/hype_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MusicReviewApp());
}

class MusicReviewApp extends StatelessWidget {
  const MusicReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Review',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HypeDashboard(),
    );
  }
}
