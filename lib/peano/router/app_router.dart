import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peano_piano/peano/pages/home.dart';
import 'package:peano_piano/peano/pages/metronome_settings.dart';
import 'package:peano_piano/peano/router/route_constants.dart';

// Create keys for `root` & `space` navigator avoiding unnecessary rebuilds
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RoutePath.home,
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      path: RoutePath.home,
      name: RouteName.home,
      builder: (BuildContext context, GoRouterState state) {
        return const Home();
      },
      routes: <RouteBase>[
        GoRoute(
          path: RoutePath.metronomeSettings,
          name: RouteName.metronomeSettings,
          builder: (BuildContext context, GoRouterState state) {
            return const MetronomeSettings();
          },
        ),
      ],
    ),
  ],
);
