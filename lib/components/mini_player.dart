import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/components/cover_image.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/pages/song_page_route.dart';
import 'package:minimal_music_player/utils/app_navigator.dart';
import 'package:minimal_music_player/utils/mini_player_route_observer.dart';

/// Persistent playback bar shown above the bottom of the screen on every
/// page while a song is loaded — mirrors the Spotify/YouTube Music pattern
/// so playback survives navigation and stays controllable without having
/// to reopen the full song page.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: MiniPlayerRouteObserver.isSongPageOnTop,
      builder: (context, isSongPageOnTop, child) {
        if (isSongPageOnTop) return const SizedBox.shrink();
        return child!;
      },
      child: Consumer<PlaylistProvider>(
        builder: (context, provider, child) {
          final queue = provider.playlist;
          final index = provider.currentSongIndex;

          if (index == null || queue.isEmpty || index >= queue.length) {
            return const SizedBox.shrink();
          }

          final song = queue[index];
          final theme = Theme.of(context);
          final progress = provider.totalDuration.inMilliseconds > 0
              ? provider.currentDuration.inMilliseconds /
                    provider.totalDuration.inMilliseconds
              : 0.0;

          return Material(
            color: theme.colorScheme.secondary,
            child: InkWell(
              onTap: () =>
                  appNavigatorKey.currentState?.push(songPageRoute()),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 2,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation(Colors.green),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CoverImage(
                              path: song.albumArtImagePath,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  song.songName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.inversePrimary,
                                  ),
                                ),
                                Text(
                                  song.artistName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.inversePrimary
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              provider.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: theme.colorScheme.inversePrimary,
                            ),
                            onPressed: provider.pauseOrResume,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.skip_next,
                              color: theme.colorScheme.inversePrimary,
                            ),
                            onPressed: provider.playNextSong,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
