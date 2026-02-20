import 'dart:async';
import 'package:flutter/material.dart';
import '../models/music_release.dart';

class ReleaseCard extends StatefulWidget {
  const ReleaseCard({
    super.key,
    required this.release,
    this.width = 150, // Updated default width for a sleeker look
  });

  final MusicRelease release;
  final double width;

  @override
  State<ReleaseCard> createState() => _ReleaseCardState();
}

class _ReleaseCardState extends State<ReleaseCard> {
  static const Color _amberAccent = Color(0xFFFFB300);
  
  Timer? _timer;
  Duration? _timeRemaining;
  bool _isReleased = false;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateCountdown();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now().toUtc();
    final releaseDate = widget.release.targetReleaseDate;
    final difference = releaseDate.difference(now);

    setState(() {
      if (difference.isNegative) {
        _isReleased = true;
        _timeRemaining = null;
      } else {
        _isReleased = false;
        _timeRemaining = difference;
      }
    });
  }

  String _formatCountdown(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    return '${days}D ${hours}H ${minutes}M';
  }

  static const Color _surfaceColor = Color(0xFF1A1A1C);
  static const Color _secondaryGrey = Color(0xFF808080);

  static const double _cardHeight = 210;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: _cardHeight,
      child: Container(
        decoration: const BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork: fixed square at top (aspect ratio 1:1)
            SizedBox(
              width: widget.width,
              height: widget.width,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      widget.release.artworkUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        color: const Color(0xFF18181B),
                        child: const Icon(Icons.music_note, color: Colors.white24),
                      ),
                    ),
                  ),
                  // Timer badge: tight #000000 pill at bottom-left, opacity 0.7
                  if (!_isReleased && _timeRemaining != null)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatCountdown(_timeRemaining!),
                          style: const TextStyle(
                            color: _amberAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Text area: fixed height via Expanded for uniform card dimensions
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.release.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.release.artistName,
                      style: const TextStyle(
                        color: _secondaryGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}