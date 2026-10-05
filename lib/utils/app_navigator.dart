import 'package:flutter/material.dart';

/// Lets widgets outside the Navigator's own subtree (like the persistent
/// MiniPlayer, which sits as a sibling of MaterialApp's routed content)
/// still push/pop routes.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
