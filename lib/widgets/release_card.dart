import 'dart:async';

import 'package:flutter/material.dart';
import '../models/music_release.dart';

/// Widget displaying a music release card with countdown timer and artwork.
/// Used in the horizontal "Dropping This Week" carousel.
class ReleaseCard extends StatefulWidget {
  const ReleaseCard({
    super.key,
    required this.release,
    this.width = 220,
    this.height = 320,
  });

  final MusicRelease release;
  final double width;
  /// Card height; must match carousel row height to avoid overflow.
  final double height;

  @override
  State<ReleaseCard> createState() => _ReleaseCardState();
}

class _ReleaseCardState extends State<ReleaseCard> {
  static const double _artworkSize = 180;

  Timer? _timer;
  Duration? _timeRemaining;
  bool _isReleased = false;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    // Update countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    // Use UTC for comparison since targetReleaseDate is stored in UTC
    final now = DateTime.now().toUtc();
    final releaseDate = widget.release.targetReleaseDate;
    final difference = releaseDate.difference(now);

    if (difference.isNegative) {
      // Release date has passed
      setState(() {
        _isReleased = true;
        _timeRemaining = null;
      });
    } else {
      setState(() {
        _isReleased = false;
        _timeRemaining = difference;
      });
    }
  }

  String _formatCountdown(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${days.toString().padLeft(2, '0')}D:'
        '${hours.toString().padLeft(2, '0')}H:'
        '${minutes.toString().padLeft(2, '0')}M:'
        '${seconds.toString().padLeft(2, '0')}S';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Countdown timer or "Out Now" text (centered over the card)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  _isReleased
                      ? 'Out Now'
                      : _timeRemaining != null
                          ? _formatCountdown(_timeRemaining!)
                          : 'Loading...',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isReleased
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ),
          ),
          // Album artwork: fixed size, centered to align with countdown
          Center(
            child: SizedBox(
              width: _artworkSize,
              height: _artworkSize,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Album artwork
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      widget.release.artworkUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.music_note, size: 48),
                        );
                      },
                    ),
                  ),
                  // Locked state overlay (desaturated effect)
                  if (!_isReleased && _timeRemaining != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title (one line for symmetry with artist)
          Text(
            widget.release.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Artist name
          Text(
            widget.release.artistName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
