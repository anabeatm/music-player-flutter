import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minimal_music_player/components/mini_player.dart';
import 'package:minimal_music_player/firebase_options.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/themes/theme_provider.dart';
import 'package:minimal_music_player/utils/app_navigator.dart';
import 'package:minimal_music_player/utils/mini_player_route_observer.dart';
import 'package:provider/provider.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';

void main() async {
  // wait for firebase to be ready before opening the app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // theme and player state available to every screen
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      navigatorObservers: [MiniPlayerRouteObserver()],
      // watches the login: user -> home, no user -> login page
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.hasData ? const HomePage() : const AuthPage();
        },
      ),
      theme: Provider.of<ThemeProvider>(context).themeData,
      // mini player stays at the bottom of every screen
      builder: (context, child) {
        return Column(
          children: [
            Expanded(child: child ?? const SizedBox.shrink()),
            const MiniPlayer(),
          ],
        );
      },
    );
  }
}
