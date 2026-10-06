import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsService {
  static const _timeout = Duration(seconds: 10);

  // tries lyrics.ovh first, then lrclib.net; returns null if neither finds it
  static Future<String?> fetchLyrics(String artist, String title) async {
    final cleanTitle = _cleanTitle(title);
    final cleanArtist = artist.split(RegExp(r'\s*(,|&|feat\.?|ft\.?)\s*')).first;

    return await _fromOvh(cleanArtist, cleanTitle) ??
        await _fromLrclib(cleanArtist, cleanTitle);
  }

  // removes "(feat. X)", "- Remastered 2011" and similar suffixes
  static String _cleanTitle(String title) => title
      .replaceAll(RegExp(r'\s*[\(\[].*?[\)\]]'), '')
      .replaceAll(RegExp(r'\s+-\s+.*$'), '')
      .trim();

  static Future<String?> _fromOvh(String artist, String title) async {
    try {
      final uri = Uri(
        scheme: 'https',
        host: 'api.lyrics.ovh',
        pathSegments: ['v1', artist, title],
      );
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final lyrics = data['lyrics'] as String?;
      return (lyrics == null || lyrics.trim().isEmpty) ? null : lyrics;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _fromLrclib(String artist, String title) async {
    try {
      final uri = Uri.https('lrclib.net', '/api/get', {
        'artist_name': artist,
        'track_name': title,
      });
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final lyrics = data['plainLyrics'] as String?;
      return (lyrics == null || lyrics.trim().isEmpty) ? null : lyrics;
    } catch (_) {
      return null;
    }
  }
}
