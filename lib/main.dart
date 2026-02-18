// Run: flutter run (or flutter run -d chrome for web)
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/music_release.dart';

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
      home: const HypeDashboardPlaceholder(),
    );
  }
}

class HypeDashboardPlaceholder extends StatefulWidget {
  const HypeDashboardPlaceholder({super.key});

  @override
  State<HypeDashboardPlaceholder> createState() =>
      _HypeDashboardPlaceholderState();
}

class _HypeDashboardPlaceholderState extends State<HypeDashboardPlaceholder> {
  String _loadStatus = 'Loading…';

  @override
  void initState() {
    super.initState();
    _verifyAssetAndModel();
  }

  Future<void> _verifyAssetAndModel() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/mock_releases.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final releases = MusicRelease.listFromReleasesJson(json);
      if (!mounted) return;
      setState(() {
        _loadStatus = releases.isEmpty
            ? 'No releases loaded'
            : 'Loaded ${releases.length} releases. First: "${releases.first.title}"';
      });
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _loadStatus = 'Error: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hype Dashboard'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_loadStatus, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
