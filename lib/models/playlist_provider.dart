import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/song.dart';
import 'dart:math';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlaylistProvider extends ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<Song> _playlist = [];

  // final List<Song> _playlist = [
  //   // song 1
  //   Song(
  //     songName: "Do It",
  //     artistName: "Stray kids",
  //     albumArtImagePath: "assets/images/doit_album_cover.jpg",
  //     audioPath: "audio/stray_kids_doit_audio.mp3",
  //   ),
  //   // song 2
  //   Song(
  //     songName: "No one noticed",
  //     artistName: "The Marias",
  //     albumArtImagePath: "assets/images/the_marias_album_cover.jpg",
  //     audioPath: "audio/no_one_noticed_the_marias_audio.mp3",
  //   ),
  //   // song 3
  //   Song(
  //     songName: "Nana OST",
  //     artistName: "Rose",
  //     albumArtImagePath: "assets/images/nana_album_cover.jpg",
  //     audioPath: "audio/nana_audio.mp3",
  //   ),
  // ];

  // current song playing index
  int? _currentSongIndex;

  // audioplayer

  final AudioPlayer _audioPlayer = AudioPlayer();

  // durations

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // constructor

  PlaylistProvider() {
    listenToDuration();
  }

  // initially not playing

  bool _isPlaying = false;

  // adding shuffle and repeat
  bool _isShuffleMode = false;
  bool _isRepeatMode = false;

  // add new song
  void addSong(Song newSong) {
    _playlist.add(newSong);
    notifyListeners();
  }

  // play the song

  void play() async {
    final String path = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(path));
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
    if (_currentSongIndex != null) {
      if (_isShuffleMode) {
        int randomIndex = Random().nextInt(_playlist.length);

        // while the index is equal current song index and the playlist length is more than one
        while (randomIndex == _currentSongIndex && _playlist.length > 1) {
          // random index receives other value from the playlist
          randomIndex = Random().nextInt(_playlist.length);
        }
        currentSongIndex = randomIndex;
      } else {
        if (_currentSongIndex! < _playlist.length - 1) {
          currentSongIndex = _currentSongIndex! + 1;
        } else {
          currentSongIndex = 0;
        }
      }
    }
  }

  // play previous

  void playPreviousSong() async {
    if (_currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    } else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        currentSongIndex = _playlist.length - 1;
      }
    }
  }

  // listen to duration

  void listenToDuration() {
    // total

    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    // current

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    // complete

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRepeatMode) {
        // if is repeat button is active, replay the current music
        seek(Duration.zero);
        play();
      } else {
        playNextSong();
      }
    });
  }

  // dispose audio

  // getters
  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  bool get isShuffleMode => _isShuffleMode;
  bool get isRepeatMode => _isRepeatMode;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  // setters

  set currentSongIndex(int? newIndex) {
    // update current song index
    _currentSongIndex = newIndex;

    if (newIndex != null) {
      play();
    }

    // update UI
    notifyListeners();
  }
}
