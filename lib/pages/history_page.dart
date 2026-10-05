import 'package:flutter/material.dart';
import 'package:minimal_music_player/components/cover_image.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/pages/song_page_route.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text("H I S T O R Y")),
      body: Consumer<PlaylistProvider>(
        builder: (context, provider, child) {
          final history = provider.history;

          if (history.isEmpty) {
            return const Center(child: Text("No recently played songs."));
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final song = history[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CoverImage(
                    path: song.albumArtImagePath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Theme.of(context).colorScheme.secondary,
                      child: const Icon(Icons.music_note),
                    ),
                  ),
                ),
                title: Text(song.songName),
                subtitle: Text(song.artistName),
                trailing: const Icon(Icons.history),
                onTap: () {
                  provider.playQueue(history, index);
                  Navigator.push(context, songPageRoute());
                },
              );
            },
          );
        },
      ),
    );
  }
}
