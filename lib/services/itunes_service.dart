import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:minimal_music_player/models/song.dart';

class ITunesService {
  static Future<List<Song>> search(String term) async {
    if (term.trim().isEmpty) return [];

    final uri = Uri.https('itunes.apple.com', '/search', {
      'term': term,
      'media': 'music',
      'entity': 'song',
      'limit': '25',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to search iTunes catalog');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List;

    return results
        .where((r) => r['previewUrl'] != null && r['trackName'] != null)
        .map((r) {
          final artwork = (r['artworkUrl100'] as String?) ?? '';
          final bigArtwork = artwork.replaceAll('100x100', '600x600');
          return Song(
            songName: r['trackName'] as String,
            artistName: (r['artistName'] as String?) ?? 'Unknown Artist',
            albumArtImagePath: _proxiedImageUrl(bigArtwork),
            audioPath: r['previewUrl'] as String,
          );
        })
        .toList();
  }

  static String _proxiedImageUrl(String url) {
    if (url.isEmpty) return url;
    final withoutScheme = url.replaceFirst(RegExp(r'^https?://'), '');
    return 'https://images.weserv.nl/?url=${Uri.encodeComponent(withoutScheme)}';
  }
}
