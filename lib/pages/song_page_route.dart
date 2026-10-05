import 'package:flutter/material.dart';
import 'package:minimal_music_player/pages/song_page.dart';

/// Route name used to detect when the full song page is on top, so the
/// mini player can hide itself instead of duplicating the same controls.
const String songPageRouteName = '/song';

Route<void> songPageRoute() {
  return MaterialPageRoute(
    settings: const RouteSettings(name: songPageRouteName),
    builder: (context) => const SongPage(),
  );
}
