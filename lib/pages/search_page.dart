import 'package:flutter/material.dart';
import 'package:minimal_music_player/components/cover_image.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/pages/song_page_route.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaylistProvider>(context);
    final allSongs = provider.allSongs;
    final filteredSongs = allSongs.where((song) {
      final nameLower = song.songName.toLowerCase();
      final artistLower = song.artistName.toLowerCase();
      final queryLower = searchQuery.toLowerCase();
      return nameLower.contains(queryLower) || artistLower.contains(queryLower);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search songs or artists...",
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.inversePrimary.withValues(alpha: 0.5),
            ),
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
      body: filteredSongs.isEmpty
          ? const Center(child: Text("No songs found."))
          : ListView.builder(
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                final song = filteredSongs[index];
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
                  onTap: () {
                    provider.playQueue(filteredSongs, index);
                    Navigator.push(context, songPageRoute());
                  },
                );
              },
            ),
    );
  }
}
