import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsService {
  // get the lyrics from lyrics.ovh, returns null if not found
  static Future<String?> fetchLyrics(String artist, String title) async {
    final uri = Uri(
      scheme: 'https',
      host: 'api.lyrics.ovh',
      pathSegments: ['v1', artist, title],
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['lyrics'] as String?;
  }
}
