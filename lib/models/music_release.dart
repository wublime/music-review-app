/// Data class for a music release (album, EP, or single).
/// Parses from [assets/data/mock_releases.json] shape.
class MusicRelease {
  const MusicRelease({
    required this.id,
    required this.title,
    required this.artistName,
    required this.artworkUrl,
    required this.releaseType,
    required this.targetReleaseDate,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
  });

  final String id;
  final String title;
  final String artistName;
  final String artworkUrl;
  final ReleaseType releaseType;
  final DateTime targetReleaseDate;
  final int likeCount;
  final int commentCount;
  final int shareCount;

  static List<MusicRelease> listFromReleasesJson(Map<String, dynamic> json) {
    final list = json['releases'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => MusicRelease.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  factory MusicRelease.fromJson(Map<String, dynamic> json) {
    return MusicRelease(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artistName: json['artist_name'] as String? ?? '',
      artworkUrl: json['artwork_url'] as String? ?? '',
      releaseType: _parseReleaseType(json['release_type'] as String?),
      targetReleaseDate: DateTime.parse(
        json['target_release_date'] as String? ?? '1970-01-01T00:00:00Z',
      ),
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      shareCount: (json['share_count'] as num?)?.toInt() ?? 0,
    );
  }

  static ReleaseType _parseReleaseType(String? value) {
    switch (value?.toLowerCase()) {
      case 'album':
        return ReleaseType.album;
      case 'ep':
        return ReleaseType.ep;
      case 'single':
        return ReleaseType.single;
      default:
        return ReleaseType.album;
    }
  }
}

enum ReleaseType {
  album,
  ep,
  single,
}
