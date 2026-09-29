import 'package:flutter/material.dart';
import 'package:minimal_music_player/components/cover_image.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/pages/song_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text("F A V O R I T E S")),
      body: Consumer<PlaylistProvider>(
        builder: (context, provider, child) {
          final favorites = provider.favorites;

          if (favorites.isEmpty) {
            return const Center(child: Text("No favorite songs yet."));
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final song = favorites[index];
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
                trailing: const Icon(Icons.favorite, color: Colors.red),
                onTap: () {
                  provider.playQueue(favorites, index);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SongPage()),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
