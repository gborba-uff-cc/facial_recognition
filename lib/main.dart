import 'package:facial_recognition/screens/placeholder/placeholder_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: _theme,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PlaceholderScreen(displayText: 'Tela principal', nextScreen: '/face_page'),
      routes: <RouteBase>[
        GoRoute(
          path: 'face_page',
          builder: (context, state) => const PlaceholderScreen(displayText: 'Tela filha', nextScreen: ''),
        ),
      ],
    ),
  ],
);