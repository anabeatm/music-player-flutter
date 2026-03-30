import 'package:flutter/material.dart';
import 'package:minimal_music_player/components/my_drawer.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/models/song.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/pages/song_page.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // get the playlist provider
  late final PlaylistProvider playlistProvider;

  @override
  void initState() {
    super.initState();

    // get playlist provider
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  // go to song
  void goToSong(int songIndex) {
    // update current song index
    playlistProvider.currentSongIndex = songIndex;
    // navigate to song page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SongPage()),
    );
  }

  // add new song
  // Mostrar formulário para adicionar nova música
  void showAddSongDialog() {
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
                            .pickFiles(type: FileType.audio);
                        if (result != null) {
                          setDialogState(() {
                            selectedAudioPath = result.files.single.path;
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
                            .pickFiles(type: FileType.image);
                        if (result != null) {
                          setDialogState(() {
                            selectedImagePath = result.files.single.path;
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

                      playlistProvider.addSong(newSong);
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("L I B R A R Y"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddSongDialog(),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          // get the playlist
          final List<Song> playlist = value.playlist;

          // return list view UI
          return ListView.builder(
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              // get individual song
              final Song song = playlist[index];

              // return list tile UI
              return ListTile(
                title: Text(song.songName),
                subtitle: Text(song.artistName),
                leading: Image.file(
                  File(song.albumArtImagePath),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                onTap: () => goToSong(index),
              );
            },
          );
        },
      ),
    );
  }
}
