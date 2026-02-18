import 'dart:convert';

import 'package:flutter/services.dart';
import '../models/music_release.dart';

/// Service for loading mock release data from assets.
class MockReleaseService {
  static const String _assetPath = 'assets/data/mock_releases.json';

  /// Loads and parses the mock releases JSON file.
  /// Returns a list of [MusicRelease] objects.
  Future<List<MusicRelease>> getReleases() async {
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return MusicRelease.listFromReleasesJson(json);
    } catch (e) {
      // In production, you might want to log this error
      return [];
    }
  }
}
