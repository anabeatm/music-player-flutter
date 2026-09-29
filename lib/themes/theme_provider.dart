import 'package:flutter/material.dart';
import 'package:minimal_music_player/themes/light_mode.dart';
import 'package:minimal_music_player/themes/dark_mode.dart';

class ThemePreset {
  final String name;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  ThemePreset({
    required this.name,
    required this.lightTheme,
    required this.darkTheme,
  });
}

class ThemeProvider extends ChangeNotifier {
  late final List<ThemePreset> _systemPresets;

  final List<ThemePreset> _customPreset = [];

  late ThemePreset _currentPreset;
  bool _isDarkMode = false;

  ThemeProvider() {
    final defaultPreset = ThemePreset(
      name: "Monochromatic",
      lightTheme: lightMode,
      darkTheme: darkMode,
    );

    final bluePreset = _generatePresetFromColor("Ocean Blue", Colors.blue);
    final greenPreset = _generatePresetFromColor("Forest Green", Colors.green);
    final purplePreset = _generatePresetFromColor(
      "Galaxy Purple",
      Colors.purple,
    );

    _systemPresets = [defaultPreset, bluePreset, greenPreset, purplePreset];
    _currentPreset = defaultPreset;
  }

  // get
  ThemeData get themeData =>
      _isDarkMode ? _currentPreset.darkTheme : _currentPreset.lightTheme;
  ThemePreset get currentPreset => _currentPreset;
  List<ThemePreset> get allPresets => [..._systemPresets, ..._customPreset];

  // is dark
  bool get isDarkMode => _isDarkMode;

  // toggle theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPreset(ThemePreset preset) {
    _currentPreset = preset;
    notifyListeners();
  }

  void addCustomPreset(String name, Color seedColor) {
    final newPreset = _generatePresetFromColor(name, seedColor);
    _customPreset.add(newPreset);
    setPreset(newPreset);
  }

  ThemePreset _generatePresetFromColor(String name, Color color) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Brightness.dark,
    );

    // This app uses colorScheme.inversePrimary as its general "text/icon on
    // surface" color everywhere (see song_page, settings_page, my_drawer,
    // etc). Material 3's own inversePrimary is meant for content on a dark
    // inverseSurface, not on the regular surface — using it as-is here gives
    // low-contrast, mismatched text on generated presets. Overriding it with
    // onSurface keeps every preset readable and consistent with the
    // hand-tuned monochromatic theme.
    return ThemePreset(
      name: name,
      lightTheme: ThemeData(
        colorScheme: lightScheme.copyWith(inversePrimary: lightScheme.onSurface),
      ),
      darkTheme: ThemeData(
        colorScheme: darkScheme.copyWith(inversePrimary: darkScheme.onSurface),
      ),
    );
  }
}
