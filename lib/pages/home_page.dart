import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimal_music_player/components/cover_image.dart';
import 'package:minimal_music_player/components/my_drawer.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/models/my_playlist.dart';
import 'package:minimal_music_player/pages/playlist_page.dart';
import 'package:minimal_music_player/utils/blob_url.dart';
import 'package:minimal_music_player/utils/mime_type.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PlaylistProvider playlistProvider;

  @override
  void initState() {
    super.initState();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  void showCreatePlaylistDialog() {
    TextEditingController nameController = TextEditingController();
    String? selectedPlaylistImagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: const Text("New Playlist"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Playlist Name",
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
                            selectedPlaylistImagePath = path;
                          });
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: Text(
                        selectedPlaylistImagePath == null
                            ? "Choose Cover Image"
                            : "Image Selected!",
                      ),
                    ),

                    if (selectedPlaylistImagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: CoverImage(
                          path: selectedPlaylistImagePath!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
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
                        selectedPlaylistImagePath != null) {
                      playlistProvider.createPlaylist(
                        nameController.text,
                        selectedPlaylistImagePath!,
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please enter a name and choose an image.",
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
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void goToPlaylist(MyPlaylist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlaylistPage(playlist: playlist)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("L I B R A R Y"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showCreatePlaylistDialog(),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          final List<MyPlaylist> playlists = value.playlists;

          if (playlists.isEmpty) {
            return const Center(child: Text("No playlists yet. Create one!"));
          }

          return ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final MyPlaylist playlist = playlists[index];

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CoverImage(
                    path: playlist.playlistImagePath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.queue_music, size: 40),
                  ),
                ),
                title: Text(
                  playlist.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${playlist.songs.length} songs"),
                onTap: () => goToPlaylist(playlist),
              );
            },
          );
        },
      ),
    );
  }
}
