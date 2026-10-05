import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:minimal_music_player/components/cover_image.dart';
import 'package:minimal_music_player/models/song.dart';
import 'package:minimal_music_player/models/my_playlist.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/pages/song_page_route.dart';
import 'package:minimal_music_player/utils/blob_url.dart';
import 'package:minimal_music_player/utils/mime_type.dart';

class PlaylistPage extends StatefulWidget {
  final MyPlaylist playlist;

  const PlaylistPage({super.key, required this.playlist});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  void goToSong(int songIndex, PlaylistProvider provider) {
    provider.playFromPlaylist(widget.playlist, songIndex);

    Navigator.push(context, songPageRoute());
  }

  Future<void> confirmDeleteSong(
    PlaylistProvider provider,
    int songIndex,
  ) async {
    final Song song = widget.playlist.songs[songIndex];
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Delete music"),
        content: Text("Remove \"${song.songName}\" from this playlist?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      provider.removeSongFromPlaylist(widget.playlist, songIndex);
    }
  }

  void showAddSongDialog(PlaylistProvider provider) {
    TextEditingController nameController = TextEditingController();
    TextEditingController artistController = TextEditingController();
    String? selectedAudioPath;
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: const Text("New music"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Music name",
                      ),
                    ),
                    TextField(
                      controller: artistController,
                      decoration: const InputDecoration(
                        labelText: "Artist name",
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.inversePrimary,
                      ),
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(type: FileType.audio, withData: true);
                        if (result != null) {
                          final file = result.files.single;
                          final String path = kIsWeb
                              ? createBlobUrl(
                                  file.bytes!,
                                  guessAudioMimeType(file.extension),
                                )
                              : file.path!;
                          setDialogState(() {
                            selectedAudioPath = path;
                          });
                        }
                      },
                      icon: const Icon(Icons.audiotrack),
                      label: Text(
                        selectedAudioPath == null
                            ? "Choose audio"
                            : "Audio selected!",
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.inversePrimary,
                      ),
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(type: FileType.image, withData: true);
                        if (result != null) {
                          final file = result.files.single;
                          final String path = kIsWeb
                              ? createBlobUrl(
                                  file.bytes!,
                                  guessImageMimeType(file.extension),
                                )
                              : file.path!;
                          setDialogState(() {
                            selectedImagePath = path;
                          });
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: Text(
                        selectedImagePath == null
                            ? "Choose image album"
                            : "Image selected!",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        artistController.text.isNotEmpty &&
                        selectedAudioPath != null &&
                        selectedImagePath != null) {
                      Song newSong = Song(
                        songName: nameController.text,
                        artistName: artistController.text,
                        albumArtImagePath: selectedImagePath!,
                        audioPath: selectedAudioPath!,
                      );
                      provider.addSongToPlaylist(widget.playlist, newSong);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please fill all fields and select files.",
                          ),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.inversePrimary,
                  ),
                  child: const Text("Save"),
                ),
              ],
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
        final List<Song> songs = widget.playlist.songs;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(widget.playlist.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => showAddSongDialog(value),
              ),
            ],
          ),
          body: songs.isEmpty
              ? const Center(child: Text("Playlist is empty. Add some songs!"))
              : ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final Song song = songs[index];

                    return ListTile(
                      title: Text(song.songName),
                      subtitle: Text(song.artistName),

                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CoverImage(
                            path: song.albumArtImagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  child: const Icon(Icons.music_note),
                                ),
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => confirmDeleteSong(value, index),
                      ),
                      onTap: () => goToSong(index, value),
                    );
                  },
                ),
        );
      },
    );
  }
}
