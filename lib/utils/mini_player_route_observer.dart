import 'package:flutter/material.dart';
import 'package:minimal_music_player/pages/song_page_route.dart';

/// Tracks whether the full SongPage is the topmost route, so the mini
/// player (shown globally) can hide itself there instead of stacking two
/// sets of playback controls on screen at once.
class MiniPlayerRouteObserver extends NavigatorObserver {
  static final ValueNotifier<bool> isSongPageOnTop = ValueNotifier(false);

  void _update(Route<dynamic>? route) {
    isSongPageOnTop.value = route?.settings.name == songPageRouteName;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _update(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _update(previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _update(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _update(newRoute);
  }
}
