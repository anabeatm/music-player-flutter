import 'package:flutter/material.dart';
import 'package:minimal_music_player/components/cover_image.dart';
import 'package:minimal_music_player/components/neu_box.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/models/song.dart';
import 'package:minimal_music_player/services/lyrics_service.dart';

class SongPage extends StatelessWidget {
  const SongPage({super.key});

  void _showLyrics(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return FutureBuilder<String?>(
              future: LyricsService.fetchLyrics(song.artistName, song.songName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final lyrics = snapshot.data;
                if (snapshot.hasError ||
                    lyrics == null ||
                    lyrics.trim().isEmpty) {
                  return const Center(child: Text("Lyrics not found."));
                }
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.songName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          song.artistName,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Text(lyrics, style: const TextStyle(height: 1.5)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        final playlist = value.playlist;
        final currentSongIndex = value.currentSongIndex;
        if (currentSongIndex == null || playlist.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("S O N G")),
            body: const Center(child: Text("Playlist is empty.")),
          );
        }
        final song = playlist[currentSongIndex];
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(song.songName),
            actions: [
              IconButton(
                icon: const Icon(Icons.lyrics_outlined),
                onPressed: () => _showLyrics(context, song),
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxHeight * 0.4,
                            ),
                            child: NeuBox(
                              child: AspectRatio(
                                aspectRatio: 1 / 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CoverImage(
                                    path: song.albumArtImagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.music_note,
                                                  size: 80,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.songName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  song.artistName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.inversePrimary,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => value.toggleFavorite(song),
                              child: Icon(
                                value.isFavorite(song)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formatDuration(value.currentDuration)),
                                GestureDetector(
                                  onTap: value.toggleShuffle,
                                  child: Icon(
                                    Icons.shuffle,
                                    color: value.isShuffleMode
                                        ? Colors.green
                                        : Theme.of(
                                            context,
                                          ).colorScheme.inversePrimary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: value.toggleRepeat,
                                  child: Icon(
                                    value.isRepeatMode
                                        ? Icons.repeat_one
                                        : Icons.repeat,
                                    color: value.isRepeatMode
                                        ? Colors.green
                                        : Theme.of(
                                            context,
                                          ).colorScheme.inversePrimary,
                                  ),
                                ),
                                Text(formatDuration(value.totalDuration)),
                              ],
                            ),

                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 0,
                                ),
                              ),
                              child: Slider(
                                min: 0,
                                max: value.totalDuration.inSeconds.toDouble(),
                                value: value.currentDuration.inSeconds
                                    .toDouble(),
                                activeColor: Colors.green,
                                onChanged: (double newValue) {},
                                onChangeEnd: (double newValue) {
                                  value.seek(
                                    Duration(seconds: newValue.toInt()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: value.playPreviousSong,
                                child: const NeuBox(
                                  child: Icon(Icons.skip_previous),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: value.pauseOrResume,
                                child: NeuBox(
                                  child: Icon(
                                    value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: GestureDetector(
                                onTap: value.playNextSong,
                                child: const NeuBox(
                                  child: Icon(Icons.skip_next),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
}
