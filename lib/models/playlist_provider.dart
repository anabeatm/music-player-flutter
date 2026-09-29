import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/my_playlist.dart';
import 'package:minimal_music_player/models/song.dart';
import 'dart:math';

class PlaylistProvider extends ChangeNotifier {
  // final List<Song> _playlist = [];

  // PLAYLISTS

  final List<MyPlaylist> _playlists = [];
  List<MyPlaylist> get playlists => _playlists;

  void createPlaylist(String name, String imagePath) {
    _playlists.add(
      MyPlaylist(name: name, playlistImagePath: imagePath, songs: []),
    );
    saveData();
    notifyListeners();
  }

  void addSongToPlaylist(MyPlaylist playlist, Song newSong) {
    playlist.songs.add(newSong);
    saveData();
    notifyListeners();
  }

  // QUENUE

  List<Song> _currentQueue = [];
  List<Song> get playlist => _currentQueue;
  int? _currentSongIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Song> _favorites = [];
  final List<Song> _history = [];

  List<Song> get favorites => _favorites;
  List<Song> get history => _history.reversed.toList();

  List<Song> get allSongs {
    final Map<String, Song> uniqueSongs = {};
    for (var playlist in _playlists) {
      for (var song in playlist.songs) {
        uniqueSongs[song.audioPath] = song;
      }
    }
    return uniqueSongs.values.toList();
  }

  bool isFavorite(Song song) {
    return _favorites.any((s) => s.audioPath == song.audioPath);
  }

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // constructor

  PlaylistProvider() {
    listenToDuration();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadData();
      } else {
        _playlists.clear();
        _favorites.clear();
        _history.clear();
        _currentQueue = [];
        _currentSongIndex = null;
        notifyListeners();
      }
    });
  }

  // initially not playing

  bool _isPlaying = false;

  // adding shuffle and repeat
  bool _isShuffleMode = false;
  bool _isRepeatMode = false;

  void playFromPlaylist(MyPlaylist selectedPlaylist, int songIndex) {
    _currentQueue = selectedPlaylist.songs;
    currentSongIndex = songIndex;
  }

  // play the song

  void play() async {
    if (_currentQueue.isEmpty || _currentSongIndex == null) return;

    final currentSong = _currentQueue[_currentSongIndex!];

    final String path = currentSong.audioPath;
    await _audioPlayer.stop();
    try {
      if (path.startsWith('http') || path.startsWith('blob:')) {
        await _audioPlayer.play(UrlSource(path));
      } else {
        await _audioPlayer.play(DeviceFileSource(path));
      }
    } catch (_) {
      _isPlaying = false;
      notifyListeners();
      return;
    }

    if (_history.isEmpty || _history.last.audioPath != currentSong.audioPath) {
      _history.add(currentSong);
      if (_history.length > 50) _history.removeAt(0);
      saveData();
    }

    _isPlaying = true;
    notifyListeners();
  }

  // pause

  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // resume

  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  // pause or resume

  void pauseOrResume() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }

    notifyListeners();
  }

  // shuffle

  void toggleShuffle() {
    _isShuffleMode = !_isShuffleMode;
    notifyListeners();
  }

  // repeat

  void toggleRepeat() {
    _isRepeatMode = !_isRepeatMode;
    notifyListeners();
  }

  // seek to a position

  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // play next

  void playNextSong() {
    if (_currentSongIndex != null && _currentQueue.isNotEmpty) {
      if (_isShuffleMode) {
        int randomIndex = Random().nextInt(_currentQueue.length);
        while (randomIndex == _currentSongIndex && _currentQueue.length > 1) {
          randomIndex = Random().nextInt(_currentQueue.length);
        }
        currentSongIndex = randomIndex;
      } else {
        if (_currentSongIndex! < _currentQueue.length - 1) {
          currentSongIndex = _currentSongIndex! + 1;
        } else {
          currentSongIndex = 0;
        }
      }
    }
  }

  // play previous

  void playPreviousSong() async {
    if (_currentQueue.isEmpty) return;
    if (_currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    } else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        currentSongIndex = _currentQueue.length - 1;
      }
    }
  }

  // listen to duration

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRepeatMode) {
        seek(Duration.zero);
        play();
      } else {
        playNextSong();
      }
    });
  }

  void toggleFavorite(Song song) {
    if (isFavorite(song)) {
      _favorites.removeWhere((s) => s.audioPath == song.audioPath);
    } else {
      _favorites.add(song);
    }
    saveData();
    notifyListeners();
  }

  void playQueue(List<Song> queue, int songIndex) {
    _currentQueue = queue;
    currentSongIndex = songIndex;
  }

  // dispose audio

  // getters
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  bool get isShuffleMode => _isShuffleMode;
  bool get isRepeatMode => _isRepeatMode;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  // setters

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) {
      play();
    }
    notifyListeners();
  }

  // load and save (Firestore, scoped by logged-in user)

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> saveData() async {
    final uid = _uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      'playlists': _playlists.map((p) => p.toJson()).toList(),
      'favorites': _favorites.map((s) => s.toJson()).toList(),
      'history': _history.map((s) => s.toJson()).toList(),
    }, SetOptions(merge: true));
  }

  Future<void> loadData() async {
    final uid = _uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();

    _playlists.clear();
    _favorites.clear();
    _history.clear();

    if (data != null) {
      final List? playlistsData = data['playlists'];
      if (playlistsData != null) {
        _playlists.addAll(
          playlistsData.map(
            (p) => MyPlaylist.fromJson(Map<String, dynamic>.from(p)),
          ),
        );
      }

      final List? favoritesData = data['favorites'];
      if (favoritesData != null) {
        _favorites.addAll(
          favoritesData.map(
            (s) => Song.fromJson(Map<String, dynamic>.from(s)),
          ),
        );
      }

      final List? historyData = data['history'];
      if (historyData != null) {
        _history.addAll(
          historyData.map((s) => Song.fromJson(Map<String, dynamic>.from(s))),
        );
      }
    }

    notifyListeners();
  }
}
