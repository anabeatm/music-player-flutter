import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/components/cover_image.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/models/song.dart';
import 'package:minimal_music_player/services/itunes_service.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _previewPlayer = AudioPlayer();

  List<Song> _results = [];
  bool _isLoading = false;
  String? _error;
  String? _playingPreviewUrl;

  @override
  void dispose() {
    _controller.dispose();
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _search(String term) async {
    if (term.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await ITunesService.search(term);
      setState(() {
        _results = results;
      });
    } catch (_) {
      setState(() {
        _error = "Couldn't search for songs. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _togglePreview(Song song) async {
    if (_playingPreviewUrl == song.audioPath) {
      await _previewPlayer.stop();
      setState(() => _playingPreviewUrl = null);
    } else {
      await _previewPlayer.stop();
      await _previewPlayer.play(UrlSource(song.audioPath));
      setState(() => _playingPreviewUrl = song.audioPath);
    }
  }

  void _showAddToPlaylistDialog(Song song) {
    final provider = Provider.of<PlaylistProvider>(context, listen: false);
    final playlists = provider.playlists;

    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Create a playlist first.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text("Add to playlist"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  title: Text(playlist.name),
                  subtitle: Text("${playlist.songs.length} songs"),
                  onTap: () {
                    provider.addSongToPlaylist(playlist, song);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Added to \"${playlist.name}\""),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search the online catalog...",
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.inversePrimary.withValues(alpha: 0.5),
            ),
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          onSubmitted: _search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_controller.text),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_results.isEmpty) {
      return const Center(
        child: Text("Search for songs in the iTunes catalog."),
      );
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final song = _results[index];
        final isPlaying = _playingPreviewUrl == song.audioPath;

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 50,
              child: CoverImage(
                path: song.albumArtImagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.secondary,
                  child: const Icon(Icons.music_note),
                ),
              ),
            ),
          ),
          title: Text(song.songName, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(song.artistName, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => _togglePreview(song),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: isPlaying ? Colors.green : null,
              ),
              IconButton(
                icon: const Icon(Icons.playlist_add),
                onPressed: () => _showAddToPlaylistDialog(song),
              ),
            ],
          ),
        );
      },
    );
  }
}
