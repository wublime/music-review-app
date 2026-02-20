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
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        title: const Text(
          'hype',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFF0F0F10),
        shape: const Border(
          bottom: BorderSide.none,
        ),
        leading: const Icon(
          Icons.calendar_today_outlined,
          color: Colors.white,
          size: 20,
        ),
        actions: const [
          Icon(
            Icons.settings_outlined,
            color: Colors.white,
            size: 20,
          ),
        ],
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
                        // Section header: "DROPPING THIS WEEK"
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 16),
                          child: Text(
                            'DROPPING THIS WEEK',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Horizontal carousel: 16px edge padding, 16px between cards, snap physics
                        SizedBox(
                          height: 210,
                          child: LayoutBuilder(
                            builder: (context, _) {
                              const cardWidth = 140.0;
                              const gap = 16.0;
                              final screenWidth =
                                  MediaQuery.of(context).size.width;
                              final viewportFraction =
                                  (cardWidth + gap) / screenWidth;
                              return PageView.builder(
                                padEnds: false,
                                controller: PageController(
                                  viewportFraction: viewportFraction,
                                ),
                                physics: const PageScrollPhysics(),
                                itemCount: _upcomingReleases.length,
                                itemBuilder: (context, index) {
                                  final release = _upcomingReleases[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: index == 0 ? 16 : gap / 2,
                                      right: index ==
                                              _upcomingReleases.length - 1
                                          ? 16
                                          : gap / 2,
                                    ),
                                    child: ReleaseCard(
                                      release: release,
                                      width: cardWidth,
                                    ),
                                  );
                                },
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
