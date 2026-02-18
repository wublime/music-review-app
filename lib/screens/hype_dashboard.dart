import 'package:flutter/material.dart';
import '../models/music_release.dart';
import '../services/mock_release_service.dart';
import '../widgets/release_card.dart';

/// Main dashboard screen displaying the "Dropping This Week" carousel.
class HypeDashboard extends StatefulWidget {
  const HypeDashboard({super.key});

  @override
  State<HypeDashboard> createState() => _HypeDashboardState();
}

class _HypeDashboardState extends State<HypeDashboard> {
  final MockReleaseService _service = MockReleaseService();
  List<MusicRelease> _allReleases = [];
  List<MusicRelease> _upcomingReleases = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReleases();
  }

  Future<void> _loadReleases() async {
    try {
      final releases = await _service.getReleases();
      // Use UTC for comparison since targetReleaseDate is stored in UTC
      final now = DateTime.now().toUtc();

      // Filter to show only upcoming releases (targetReleaseDate is in the future)
      final upcoming = releases
          .where((release) => release.targetReleaseDate.isAfter(now))
          .toList();

      // Sort by release date (soonest first)
      upcoming.sort((a, b) =>
          a.targetReleaseDate.compareTo(b.targetReleaseDate));

      if (mounted) {
        setState(() {
          _allReleases = releases;
          _upcomingReleases = upcoming;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hype Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReleases,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _upcomingReleases.isEmpty
                  ? const Center(
                      child: Text('No upcoming releases found.'),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: "DROPPING THIS WEEK:"
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Text(
                            'DROPPING THIS WEEK:',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                        // Horizontal carousel
                        SizedBox(
                          height: 320, // Fixed height for carousel
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _upcomingReleases.length,
                            itemBuilder: (context, index) {
                              final release = _upcomingReleases[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: ReleaseCard(
                                  release: release,
                                  width: 220,
                                ),
                              );
                            },
                          ),
                        ),
                        // Spacer for future content below
                        const Expanded(child: SizedBox()),
                      ],
                    ),
    );
  }
}
